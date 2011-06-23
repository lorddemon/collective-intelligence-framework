use inc::Module::Install;

all_from    'lib/CIF/Archive/Analytic.pm';
requires    'CIF::Client'   => '0.0101';
requires    'CIF::Archive'  => '0.01';

install_script  'cif_analytic';

WriteAll();
