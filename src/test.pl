$regex = 's/[a-c]//g';

$something = 'abcdef';
$qualifier = 'g';

$another = "\$something =~ ".$regex;
eval($another);
print $something."\n";
