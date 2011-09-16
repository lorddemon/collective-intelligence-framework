# everything here should be lower case
Set(%CIFMinimal_RestrictionMapping,
       default         => 'amber',
       red             => 'private',
       amber           => 'need-to-know',
       #green          => 'need-to-know',
       #white          => 'public',
);

Set(@CIFMinimal_Assessments, 'botnet','malware/exploit','hijacked','phishing','scanner','fastflux','suspicious');
Set($CIFMinimal_DefaultAssessment,'botnet');
Set($CIFMinimal_DefaultSharingPolicy,'http://en.wikipedia.org/wiki/Traffic_Light_Protocol');
Set($CIFMinimal_DefaultConfidence, 85);
Set($CIFMinimal_RejectPrivateAddress,1);
Set($CIFMinimal_HelpUrl,'http://code.google.com/p/collective-intelligence-framework/');

1;
