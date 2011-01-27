#                                               -*- Autoconf -*-
# Process this file with autoconf to produce a configure script.

AC_PREREQ([2.64])
AC_INIT([cif-feeds-public], [0.01_01], [ci-framework@googlegroups.com])
AM_INIT_AUTOMAKE(cif-feeds-public,0.01_01)
AC_PREFIX_DEFAULT([/opt/cif-feeds-public])

# Checks for programs.

# Checks for libraries.

# Checks for header files.

# Checks for typedefs, structures, and compiler characteristics.

# Checks for library functions.

AC_CONFIG_FILES([
    Makefile
    src/Makefile
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
