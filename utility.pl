use Term::ANSIColor;
use IO::Socket::INET;
use JSON;
use Scalar::Util qw(looks_like_number);
sub randnum {
    my @arr = @_;
   
    for (my $i =0; $i < 5; $i++) {
        while(1) {
            my $indexi = int(rand(5));
            my $indexj = int(rand(5));
            if ($arr[$indexi][$indexj]!=1) {
                $arr[$indexi][$indexj] = 1;
                last;
            }
            
        }
    }

    print "\n";
    for (my $i =0; $i < 5; $i++) {
        
        while(1) {
            my $indexi = int(rand(5));
            my $indexj = int(rand(5));
            if ($arr[$indexi][$indexj]!=1 && $arr[$indexi][$indexj]!=2) {
                $arr[$indexi][$indexj] = 2;
                last;
            }
            
        }
        
    }
    return @arr;
}

sub SendBattlefield {
    my @arg = @_;
    my $encoded = $arg[0];
    my $socket = $arg[1];
    # my $encoded = encode_json(\@arr);
    # $client_socket->recv($data, 1024);
    $socket->send($encoded);
}

sub ReceiveBattleField {
    my @arg = @_;
    my $response = $arg[0];
    my @chars = split("", $response);
    my $string="";
    foreach my $s (@chars) {
                if (looks_like_number($s)) {
                    $string = $string . $s;
                }   
            }

    my @chars = split("", $string);

    my @arr = ([0, 0, 0, 0, 0],[0, 0, 0, 0, 0],[0, 0, 0, 0, 0],[0, 0, 0, 0, 0],[0, 0, 0, 0, 0]);
    my $x=0;
    for (my $i =0; $i < 5; $i++) {
        for (my $j = 0; $j < 5; $j++) {
            
            for (;$x < 25;) {
                $arr[$i][$j] = $chars[$x];
                last;
            }
            $x++;
        }
    }
    BattlefieldDisplay(@arr);
    return @arr;
}

sub ThrowDie {
    my $dienum = int(rand(6)) + 1;
    if ($dienum % 2 ==0) {
        return "Server turn";
    }
    else {
        return "Client turn";
    }
}

sub ServerMove {
    my @arr = @_;
    my %addressindexj = (0 => "A", 1=> "B", 2 => "C",3 => "D", 4 => "E");
    %addressindexj = reverse %addressindexj;
    my $again = 0;
    while (1) {
        while (1) {
            print "Choose your ship: ";
            chomp(my $inputchoose = <STDIN>);
            my $validinput = CheckValidCoordinate($inputchoose);
            if ($validinput eq "false") {
                next;
            }
            $index1choose = substr($inputchoose, 0, 1);
            $index2choose = substr($inputchoose, 1, 1);
            if ($arr[$index1choose][%addressindexj{$index2choose}]==1) {
                last;
            }
        }

        while (1) {
            print "Choose where to move (IGNORE to re-select your ship): ";
            chomp(my $inputmove = <STDIN>);
            my $validinput = CheckValidCoordinate($inputmove);
            if ($validinput eq "false") {
                next;
            }
            if ($inputmove eq "IGNORE") {
                $again = 1;
                last;
            }

            $index1move = substr($inputmove, 0, 1);
            $index2move = substr($inputmove, 1, 1);
            print "$index1move$index2move";
            print "$inputmove$inputchoose";
            if (($index1choose == $index1move) && ($index2choose == $index2move)) {
                print "Yes u can stay\n";
            }
            else {
                print "I dont know what happens\n";
            }
            if (($arr[$index1move][%addressindexj{$index2move}]==0) || (($index1choose == $index1move) && ($index2choose == $index2move))) {
                if ((($index1move-1)==$index1choose) || (($index1move+1)==$index1choose) || ((%addressindexj{$index2move}-1)==%addressindexj{$index2choose}) || ((%addressindexj{$index2move}+1)==%addressindexj{$index2choose})){
                    last;
                }
                elsif (($index1choose == $index1move) && ($index2choose == $index2move)) {
                    last;
                }
            }
        }
        if ($again == 0) {
            last;
        }
    }
    $arr[$index1choose][%addressindexj{$index2choose}]=0;
    $arr[$index1move][%addressindexj{$index2move}]=1;

    while (1) {
        print "[Server]Choose where to shoot: ";
        chomp(my $inputmove = <STDIN>);
        my $validinput = CheckValidCoordinate($inputmove);
        if ($validinput eq "false") {
            next;
        }
        $index1choose = substr($inputmove, 0, 1);
        $index2choose = substr($inputmove, 1, 1);
        print "Index choose : $index1choose$index2choose\n";
        print "Index choose : $index1move$index2move\n";
        print "%addressindexj{$index2choose}\n";
        print "%addressindexj{$index2move}\n";
        if ((($index1move-1)==$index1choose) || (($index1move+1)==$index1choose) || ((%addressindexj{$index2move}-1)==%addressindexj{$index2choose}) || ((%addressindexj{$index2move}+1)==%addressindexj{$index2choose})) {
                $arr[$index1choose][%addressindexj{$index2choose}] = 0;
                print "HIT!";
                last;
            
        }
    }
    BattlefieldDisplay(@arr);
    return @arr;
}

sub ClientMove {
    my @arr = @_;
    my %addressindexj = (0 => "A", 1=> "B", 2 => "C",3 => "D", 4 => "E");
    %addressindexj = reverse %addressindexj;

    while (1) {
        while (1) {
            print "Choose your ship: ";
            chomp(my $inputchoose = <STDIN>);
            my $validinput = CheckValidCoordinate($inputchoose);
            if ($validinput eq "false") {
                next;
            }
            $index1choose = substr($inputchoose, 0, 1);
            $index2choose = substr($inputchoose, 1, 1);
            if ($arr[$index1choose][%addressindexj{$index2choose}]==2) {
                last;
            }
        }

        while (1) {
            print "Choose where to move (IGNORE to re-select your ship): ";
            chomp(my $inputmove = <STDIN>);
            my $validinput = CheckValidCoordinate($inputmove);
            if ($validinput eq "false") {
                next;
            }
            if ($inputmove eq "IGNORE") {
                $again = 1;
                last;
            }
            $index1move = substr($inputmove, 0, 1);
            $index2move = substr($inputmove, 1, 1);
            print "$index1move$index2move";
            if (($arr[$index1move][%addressindexj{$index2move}]==0) || (($index1choose == $index1move) && ($index2choose == $index2move))) {
                if ((($index1move-1)==$index1choose) || (($index1move+1)==$index1choose) || (($index2move-1)==$index2choose) || (($index2move+1)==$index2choose)){
                    last;
                }
                elsif (($index1choose == $index1move) && ($index2choose == $index2move)) {
                    last;
                }
            }
        }
        if ($again == 0) {
            last;
        }
    }
    $arr[$index1choose][%addressindexj{$index2choose}]=0;
    $arr[$index1move][%addressindexj{$index2move}]=2;

    while (1) {
        print "[Client]Choose where to shoot: ";
        chomp(my $inputmove = <STDIN>);
        my $validinput = CheckValidCoordinate($inputmove);
        if ($validinput eq "false") {
            next;
        }
        $index1choose = substr($inputmove, 0, 1);
        $index2choose = substr($inputmove, 1, 1);
        print "%addressindexj{$index2choose}\n";
        if ((($index1move-1)==$index1choose) || (($index1move+1)==$index1choose) || ((%addressindexj{$index2move}-1)==%addressindexj{$index2choose}) || ((%addressindexj{$index2move}+1)==%addressindexj{$index2choose})) {
                if ($arr[$index1choose][%addressindexj{$index2choose}] == 1) {
                    print "TARGET HIT!\n";
                }
                else {
                    print "No enemy nearby\n";
                }
                $arr[$index1choose][%addressindexj{$index2choose}] = 0;
                last;
            
        }
    }
    BattlefieldDisplay(@arr);
    
    return @arr;
}

sub CheckEndGame {
    my @arr = @_;
    my $countserver = 0;
    my $countclient = 0;
    for (my $i =0; $i < 5; $i++) {     
        for (my $j = 0; $j < 5; $j++) {
            if ($arr[$i][$j]==1) {
                $countserver++;
            }
            elsif ($arr[$i][$j]==2) {
                $countclient++;
            }
            
        }
    }
    print "Number of ships of Server left: $countserver\n";
    print "Number of ships of Client left: $countclient\n";
    if ($countclient ==0) {
        return "Server wins";
    }
    elsif ($countserver == 0) {
        return "Client wins";
    }
    else {
        return "Continue";
    }

}

sub CheckValidCoordinate {
    my @arr = @_;
    my $input = @arr[0];
    print "Check input [$input]\n";
    my %addressindexj = (0 => "A", 1=> "B", 2 => "C",3 => "D", 4 => "E");
    %addressindexj = reverse %addressindexj;
    my $lengthinput = length($input);
    print "length input: $lengthinput\n";
    if (length($input)!=2) {
        return "false";
    }
    $index1 = substr($input, 0, 1);
    $index2 = substr($input, 1, 1);
    print "$index1$index2\n";
    print "(%addressindexj{$index2}\n";
    if (($index1>=0 && $index1<=4) && (%addressindexj{$index2}>=0 && %addressindexj{$index2}<=4)) {
        return "true";
    }
    else {
        return "false";
    }
}

sub BattlefieldDisplay {
    my @arr = @_;
    print "SHIP BATTLEFIELD\n\n";
    print color('bold blue');
    print "    A    B    C    D    E\n\n";
    print color('reset');
    for (my $i =0; $i < 5; $i++) {
        my $row = $i;
        print color('bold blue');
        print "$row ";
        print color('reset');
        for (my $j = 0; $j < 5; $j++) {
            if ($arr[$i][$j] == 1) {
                print color('red');
                print " [$arr[$i][$j]] ";
                print color('reset');
            }
            elsif ($arr[$i][$j] == 2) {
                print color('yellow');
                print " [$arr[$i][$j]] ";
                print color('reset');
            }
            else {
                print "  $arr[$i][$j]  ";
            }
            
        }
        print "\n\n\n";

    }
}
1