#                                               -*- Autoconf -*-
# Process this file with autoconf to produce a configure script.

AC_PREREQ([2.64])
AC_INIT([cif-sources], [0.01], [bugs@cif.com])
AM_INIT_AUTOMAKE(cif-sources,0.01)
AC_PREFIX_DEFAULT([/opt/cif-sources])

# Checks for programs.

# Checks for libraries.

# Checks for header files.

# Checks for typedefs, structures, and compiler characteristics.

# Checks for library functions.

AC_CONFIG_FILES([
    Makefile
    malware/Makefile
    networks/Makefile
    phishing/Makefile
    whitelists/Makefile
])

#dnl CIF_USER
AC_ARG_WITH(cif-user,
    AC_HELP_STRING([--with-cif-user=USER],
        [user the cif scripts will run as (default: cif)]),
    CIF_USER=$withval,
    CIF_USER=cif)
AC_SUBST(CIF_USER)

#dnl CIF_USER
AC_ARG_WITH(cif-group,
    AC_HELP_STRING([--with-cif-user=GROUP],
        [group the cif scripts will run as (default: cif)]),
    CIF_GROUP=$withval,
    CIF_GROUP=cif
)
AC_SUBST(CIF_GROUP)

AC_OUTPUT
