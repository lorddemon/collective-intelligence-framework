# don't change this... stuff will break
Set($RTIR_DisableBlocksQueue, 1);
Set($MinimalRegex, qr!^(?:/+Minimal/)!x );
my $rt_no_auth = RT->Config->Get('WebNoAuthRegex');
Set($WebNoAuthRegex, qr{ (?: $rt_no_auth | ^/+Minimal/+NoAuth/ ) }x);
Set(@Active_MakeClicky, qw(httpurl_overwrite address email domain));

# everything here should be lower case
Set(%CIFMinimal_RestrictionMapping,
       default         => 'amber',
       red             => 'private',
       amber           => 'need-to-know',
       #green          => 'need-to-know',
       #white          => 'public',
);

#Set(@CIFMinimal_Assessments, 'botnet/C2','malware/exploit','scanner/bruteforcer','hijacked','phishing','fastflux','suspicious');
Set($CIFMinimal_DefaultAssessment,'botnet/C2');
Set($CIFMinimal_DefaultSharingPolicy,'http://en.wikipedia.org/wiki/Traffic_Light_Protocol');
Set($CIFMinimal_DefaultConfidence, 85);
Set($CIFMinimal_RejectPrivateAddress,1);
Set($CIFMinimal_HelpUrl,'http://code.google.com/p/collective-intelligence-framework/');

Set(%CIFMinimal_ShareWith,
    'leo.example.com'         => {
        description     => 'Anonymized with Trusted Law Enforcement',
        checked         => 1,
    },
    'partners.example.com'    => {
        description => 'Anonymized with Trusted Mitigation Partners',
        checked     => 1,
    }
);

# this allows you to wrap the RT::User::Create function
# this example we use:
# http://www.openfusion.com.au/labs/mod_auth_tkt/
# which places "tokens" (eg: groups) in $ENV:
#  $VAR59 = 'REMOTE_USER';
#  $VAR60 = 'wes@example.com';
#  $VAR61 = 'REMOTE_USER_TOKENS';
#  $VAR62 = 'group1,group2,group3';

Set(%CIFMinimal_UserGroupMapping,
    EnvVar  => 'REMOTE_USER_TOKENS',
    Pattern => qr/,/,
    Mapping => {
        mygroup1    => 'DutyTeam group1.example.com',
        mygroup2    => 'DutyTeam group2.example.com',
        mygroup3    => 'DutyTeam group3.example.com',
    },
);

1;
