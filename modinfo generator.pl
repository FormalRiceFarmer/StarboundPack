use Cwd;
opendir(Dir,cwd()) or die "Failure Will Robinson!";
$dir = cwd();

@files = grep(/\.modpak$/,readdir(Dir));

foreach (@files) {
  my $name = substr($_, 0, -7);
  open my $file, ">", "$dir/$name.modinfo" or die "Can't open '$dir/$name.modinfo'\n";
  print $file "
{
  \"name\" : \"FormalRiceFarmer's Pack!\",
  \"version\" : \"Beta v. Enraged Koala\",
  \"path\" : \"$_\",
  \"dependencies\" : []
}";
  close $file;
  };
print "probably worked, lol. list of modpaks detected:\n";
foreach (@files){print "$_\n";};
<STDIN>