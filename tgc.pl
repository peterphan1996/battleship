print "Input a number: ";
my $n = <STDIN>;
for (my $i =1;$i<=$n;$i++) {
    print " " x ($n-$i);
    print "* " x $i;
    print "\n";
}