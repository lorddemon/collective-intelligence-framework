Redhat 5 has an issue with Scalar::Util and Zlib

# Install #

Prior to installation, re-install Scalar::Util with the following:
```
$> sudo CPAN -e 'force install Scalar::Util'
```

Install JSON::XS to solve known performance issues
```
$> sudo perl -MCPAN -e 'install JSON::XS'
```