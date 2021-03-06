#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>
#include <conio.h>
#include <em.h>
#include <peekpoke.h>

#define FORCE_ERROR1 0
#define FORCE_ERROR2 0

/* debug cart poke addresses for different platforms */
#if defined(__C64__) || defined(__C128__)
#define DEBUG_CART_ADDR 0xd7ff
#endif

#if defined(__CBM510__) || defined(__CBM610__)
#define DEBUG_CART_ADDR 0xdaff
#endif

#ifdef __PET__
#define DEBUG_CART_ADDR 0x8bff
#endif

#if defined(__C16__) || defined(__PLUS4__)
#define DEBUG_CART_ADDR 0xfdcf
#endif

#ifdef __VIC20__
#define DEBUG_CART_ADDR 0x910f
#endif

#if defined(__CBM610__) || defined(__CBM510__)
#define DEBUGPOKE(x, y) pokebsys(x, y)
#else
#define DEBUGPOKE(x, y) POKE(x, y)
#endif

#define PAGE_SIZE       128                     /* Size in words */
#define BUF_SIZE        (PAGE_SIZE + PAGE_SIZE/2)
static unsigned buf[BUF_SIZE];

extern char emd_test;

static void cleanup (void)
/* Remove the driver on exit */
{
    em_uninstall();
}



static void fill (register unsigned* page, register unsigned char count, register unsigned num)
{
    register unsigned char i;
    for (i = 0; i < count; ++i, ++page) {
        *page = num;
    }
}



static void cmp (unsigned page, register const unsigned* buf,
                 register unsigned char count, register unsigned num)
{
    register unsigned char i;
    for (i = 0; i < count; ++i, ++buf) {
        if (*buf != num) {
            cprintf ("\r\nData mismatch in page $%04X at $%04X\r\n"
                     "Data is $%04X (should be $%04X)\r\n",
                     page, buf, *buf, num);
#ifdef __ATARI__
            cgetc ();
#endif
#ifdef DEBUG_CART_ADDR
            DEBUGPOKE(DEBUG_CART_ADDR, 0xff);
#endif
            exit (EXIT_FAILURE);
        }
    }
}

int main (void)
{
    unsigned I;
    unsigned Offs;
    unsigned PageCount;
    unsigned char X, Y;
    struct em_copy c;

    clrscr ();
    if (em_install(&emd_test) != EM_ERR_OK) {
       cprintf("Hardware not found\r\n");
#ifdef DEBUG_CART_ADDR
        DEBUGPOKE(DEBUG_CART_ADDR, 0xff);
#endif
       exit (EXIT_FAILURE);
    }
    atexit (cleanup);

    /* Get the number of available pages */
    PageCount = em_pagecount ();
    cprintf ("Loaded ok, page count = $%04X\r\n", PageCount);

    /* TEST #1: em_map/em_use/em_commit */
    cputs ("Testing em_map/em_use/em_commit");

    /* Fill all pages */
    cputs ("\r\n  Filling   ");
    X = wherex ();
    Y = wherey ();
    for (I = 0; I < PageCount; ++I) {

        /* Fill the buffer and copy it to em */
        fill (em_use (I), PAGE_SIZE, I);
        em_commit ();

        /* Keep the user happy */
        gotoxy (X, Y);
        cputhex16 (I);
    }

#if FORCE_ERROR1
    ((unsigned*) em_map (0x03))[0x73] = 0xFFFF;
    em_commit ();
#endif

    /* Check all pages */
    cputs ("\r\n  Comparing ");
    X = wherex ();
    Y = wherey ();
    for (I = 0; I < PageCount; ++I) {

        /* Get the buffer and compare it */
        cmp (I, em_map (I), PAGE_SIZE, I);

        /* Keep the user happy */
        gotoxy (X, Y);
        cputhex16 (I);
    }

    /* TEST #2: em_copyfrom/em_copyto. */
    cputs ("\r\nTesting em_copyfrom/em_copyto");

    /* We're filling now 384 bytes per run to test the copy routines with
    ** other sizes.
    */
    PageCount = (PageCount * 2) / 3;

    /* Setup the copy structure */
    c.buf   = buf;
    c.count = sizeof (buf);

    /* Fill again all pages */
    cputs ("\r\n  Filling   ");
    X = wherex ();
    Y = wherey ();
    c.page = 0;
    c.offs = 0;
    for (I = 0; I < PageCount; ++I) {

        /* Fill the buffer and copy it to em */
        fill (buf, BUF_SIZE, I ^ 0xFFFF);
        em_copyto (&c);

        /* Adjust the em offset */
        Offs = c.offs + sizeof (buf);
        c.offs = (unsigned char) Offs;
        c.page += (Offs >> 8);

        /* Keep the user happy */
        gotoxy (X, Y);
        cputhex16 (I);
    }

#if FORCE_ERROR2
    c.page = 0x03;
    em_copyfrom (&c);
    buf[0x73] = 0xFFFF;
    em_copyto (&c);
#endif

    /* Check all pages */
    cputs ("\r\n  Comparing ");
    X = wherex ();
    Y = wherey ();
    c.page = 0;
    c.offs = 0;
    for (I = 0; I < PageCount; ++I) {

        /* Get the buffer and compare it */
        em_copyfrom (&c);
        cmp (I, buf, BUF_SIZE, I ^ 0xFFFF);

        /* Adjust the em offset */
        Offs = c.offs + sizeof (buf);
        c.offs = (unsigned char) Offs;
        c.page += (Offs >> 8);

        /* Keep the user happy */
        gotoxy (X, Y);
        cputhex16 (I);
    }

    /* Success */
    cprintf ("\r\nPassed!\r\n");

#ifdef __ATARI__
    cgetc ();
#endif

#ifdef DEBUG_CART_ADDR
        DEBUGPOKE(DEBUG_CART_ADDR, 0);
#endif

    return 0;
}
