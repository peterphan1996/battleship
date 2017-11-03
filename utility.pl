use JSON::XS qw(encode_json decode_json);
use File::Slurp qw(read_file write_file);
use Term::ANSIColor;
use Term::ANSIColor 2.00 qw(:pushpop);
use IO::Socket::INET;
use JSON;
use Scalar::Util qw(looks_like_number);
use strict;
use Data::Dumper;

my %hash = ('okay' => 1);
my @arr = ([0, 0, 0, 0, 0],[0, 0, 0, 0, 0],[0, 0, 0, 0, 0],[0, 0, 0, 0, 0],[0, 0, 0, 0, 0]);
DecodeJson();


sub DecodeJson {
    my $json = read_file('dump.txt', { binmode => ':raw' });
    %hash = %{ decode_json $json };
}

sub EncodeJson {
    my $json = encode_json \%hash;
    write_file('dump.txt', { binmode => ':raw' }, $json);
}

sub randnum {
    my @array = @_;
    for (my $i =0; $i < 5; $i++) {
        while(1) {
            my $indexi = int(rand(5));
            my $indexj = int(rand(5));
            if ($array[$indexi][$indexj]!=1) {
                $array[$indexi][$indexj] = 1;

                last;
            }
            
        }
    }

    print "\n";
    for (my $i =0; $i < 5; $i++) {
        
        while(1) {
            my $indexi = int(rand(5));
            my $indexj = int(rand(5));
            if ($array[$indexi][$indexj]!=1 && $array[$indexi][$indexj]!=2) {
                $array[$indexi][$indexj] = 2;
                
                last;
            }
            
        }
        
    }

    return @array;
}
    
sub SendBattlefield {
    my @arg = @_;
    my $encoded = $arg[0];
    my $socket = $arg[1];
    # my $encoded = encode_json(\@arr);
    # $client_socket->recv($data, 1024);
    sleep(1);
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

sub ClientMove {
    DecodeJson();
    my @arr = @_;
    my %addressindexj = (0 => "A", 1=> "B", 2 => "C",3 => "D", 4 => "E");
    %addressindexj = reverse %addressindexj;
    my $again = 0;
    my $inputchoose;
    my $inputmove;
    my $inputshoot;
    my $index1choose;
    my $index2choose;
    my $index1move;
    my $index2move;
    my $index1shoot;
    my $index2shoot;
    while (1) {
        while (1) {
            print color('yellow');
            print "Choose your ship: ";
            print color('reset');
            chomp($inputchoose = <STDIN>);
            my $validinput = CheckValidCoordinate($inputchoose);
            if ($validinput eq "false") {
                print "Invalid input !!! ";
                next;
            }
            $index1choose = substr($inputchoose, 0, 1);
            $index2choose = substr($inputchoose, 1, 1);
            if ($arr[$index1choose][%addressindexj{$index2choose}]==2) {
                last;
            }
        }

        while (1) {
            print color('yellow');
            print "Choose where to move (IGNORE to re-select your ship): ";
            print color('reset');
            chomp($inputmove = <STDIN>);
            my $validinput = CheckValidCoordinate($inputmove);
            if ($inputmove eq "IGNORE") {
                $again = 1;
                last;
            }
            if ($validinput eq "false") {
                print "Invalid input !!! ";
                next;
            }
            
            $index1move = substr($inputmove, 0, 1);
            $index2move = substr($inputmove, 1, 1);
            if (($index1choose == $index1move) && ($index2choose == $index2move)) {
                print "Yes you can stay\n";
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
    $arr[$index1move][%addressindexj{$index2move}]=2;
    $hash{$inputmove} = delete $hash{$inputchoose};
    EncodeJson();
    BattlefieldDisplay(@arr);

    while (1) {
        print color('yellow');
        print "[Client]Choose where to shoot: ";
        print color('reset');
        chomp($inputshoot = <STDIN>);
        my $validinput = CheckValidCoordinate($inputshoot);
        if ($validinput eq "false") {
            print "Invalid input !!! ";
            next;
        }
        $index1shoot = substr($inputshoot, 0, 1);
        $index2shoot = substr($inputshoot, 1, 1);
        # print "%addressindexj{$index2choose}\n";
        if ((($index1move-1)==$index1shoot) || (($index1move+1)==$index1shoot) || ((%addressindexj{$index2move}-1)==%addressindexj{$index2shoot}) || ((%addressindexj{$index2move}+1)==%addressindexj{$index2shoot})) {
                if ($arr[$index1shoot][%addressindexj{$index2shoot}] == 1) {
                    print "TARGET HIT!\n";
                    $hash{$inputshoot}{'HP'} = $hash{$inputshoot}{'HP'} - ($hash{$inputmove}{'Dam'} * $hash{$inputshoot}{'DamTaken'});
                    print "Enemy has $hash{$inputshoot}{'HP'} HP left !!!\n";
                    if ($hash{$inputshoot}{'HP'}<=0) {
                        delete $hash{$inputshoot};
                        $arr[$index1shoot][%addressindexj{$index2shoot}]=0;
                    }
                    EncodeJson();
                }
                else {
                    print "No enemy at that position !!!\n";
                }
                last;
            
        }
    }
    BattlefieldDisplay(@arr);
    return @arr;
}

sub ServerMove {
    DecodeJson();

    my @arr = @_;
    my %addressindexj = (0 => "A", 1=> "B", 2 => "C",3 => "D", 4 => "E");
    %addressindexj = reverse %addressindexj;
    my $again = 0;
    my $inputchoose;
    my $inputmove;
    my $inputshoot;
    my $index1choose;
    my $index2choose;
    my $index1move;
    my $index2move;
    my $index1shoot;
    my $index2shoot;
    while (1) {
        while (1) {
            $again = 0;
            print color('red');
            print "Choose your ship: ";
            print color('reset');
            chomp($inputchoose = <STDIN>);
            my $validinput = CheckValidCoordinate($inputchoose);
            if ($validinput eq "false") {
                print "Invalid input !!! ";
                next;
            }
            $index1choose = substr($inputchoose, 0, 1);
            $index2choose = substr($inputchoose, 1, 1);
            if ($arr[$index1choose][%addressindexj{$index2choose}]==1) {
                last;
            }
        }

        while (1) {
            print color('red');
            print "Choose where to move (IGNORE to re-select your ship): ";
            print color('reset');
            chomp($inputmove = <STDIN>);
            my $validinput = CheckValidCoordinate($inputmove);
            if ($inputmove eq "IGNORE") {
                $again = 1;
                last;
            }
            if ($validinput eq "false") {
                print "Invalid input !!! ";
                next;
            }
            
            $index1move = substr($inputmove, 0, 1);
            $index2move = substr($inputmove, 1, 1);
            
            if (($index1choose == $index1move) && ($index2choose == $index2move)) {
                print "Yes you can stay\n";
            }
            if (($arr[$index1move][%addressindexj{$index2move}]==0) || (($index1choose == $index1move) && ($index2choose == $index2move))) {
                if ((($index1move-1)==$index1choose) || (($index1move+1)==$index1choose) || ((%addressindexj{$index2move}-1)==%addressindexj{$index2choose}) || ((%addressindexj{$index2move}+1)==%addressindexj{$index2choose})){
                    last;
                }
                elsif (($index1choose == $index1move) && ($index2choose == $index2move)) {
                    last;
                }
                else {
                print "Something wrong in here\n";
            }
            }
            else {
                print "Something wrong\n";
            }
        }
        if ($again == 0) {
            last;
        }
    }
    $arr[$index1choose][%addressindexj{$index2choose}]=0;

    $arr[$index1move][%addressindexj{$index2move}]=1;

    $hash{$inputmove} = delete $hash{$inputchoose};
    EncodeJson();    
    BattlefieldDisplay(@arr);
    while (1) {
        print color('red');
        print "[Server]Choose where to shoot: ";
        print color('reset');
        chomp($inputshoot = <STDIN>);
        my $validinput = CheckValidCoordinate($inputshoot);
        if ($validinput eq "false") {
            print "Invalid input !!! ";
            next;
        }
        $index1shoot = substr($inputshoot, 0, 1);
        $index2shoot = substr($inputshoot, 1, 1);
        if ((($index1move-1)==$index1shoot) || (($index1move+1)==$index1shoot) || ((%addressindexj{$index2move}-1)==%addressindexj{$index2shoot}) || ((%addressindexj{$index2move}+1)==%addressindexj{$index2shoot})) {
                if ($arr[$index1shoot][%addressindexj{$index2shoot}] == 2) {
                    print "TARGET HIT!\n";

                    $hash{$inputshoot}{'HP'} = $hash{$inputshoot}{'HP'} - ($hash{$inputmove}{'Dam'} * $hash{$inputshoot}{'DamTaken'});
                    print "Enemy has $hash{$inputshoot}{'HP'} HP left !!!\n";
                    
                    if ($hash{$inputshoot}{'HP'}<=0) {
                        delete $hash{$inputshoot};
                    $arr[$index1shoot][%addressindexj{$index2shoot}]=0;    
                    }

                    EncodeJson();
                }
                else {
                    print "No enemy at that position !!!\n";
                }
                
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
    # print "Check input [$input]\n";
    my %addressindexj = (0 => "A", 1=> "B", 2 => "C",3 => "D", 4 => "E");
    %addressindexj = reverse %addressindexj;
    my $lengthinput = length($input);
    # print "length input: $lengthinput\n";
    if (length($input)!=2) {
        return "false";
    }
    my $index1 = substr($input, 0, 1);
    my $index2 = substr($input, 1, 1);
    # print "$index1$index2\n";
    # print "($addressindexj{$index2}\n";
    if ((looks_like_number($addressindexj{$index2})) && ($index1>=0 && $index1<=4) && (%addressindexj{$index2}>=0 && %addressindexj{$index2}<=4)) {
        # print "OK\n";
        return "true";
    }
    else {
        # print "NOT OK\n";
        return "false";
    }
}


sub ConvertCoordinate {
    my @arr = @_;
    my $coor = @arr[0];
    my %addressindexj = (0 => "A", 1=> "B", 2 => "C",3 => "D", 4 => "E");
    my $index1 = substr($coor, 0, 1);
    my $index2 = substr($coor, 1, 1);
    my $converted = $index1 . $addressindexj{$index2};
    return $converted;
}

sub BattlefieldDisplayOnServer {
    my @arr = @_;
    DecodeJson();
    print "SHIP BATTLEFIELD\n\n";
    print color('bold blue');
    print "     A      B      C      D      E\n\n";
    print color('reset');
    for (my $i =0; $i < 5; $i++) {
        my $row = $i;
        print color('bold blue');
        print "$row ";
        print color('reset');
        for (my $j = 0; $j < 5; $j++) {
            if ($arr[$i][$j] == 1) {
                my $converted = ConvertCoordinate($i.$j);
                print color('red');
                if ($hash{$converted}{'HP'} <100) {
                    if ($hash{$converted}{'DamTaken'}==0.5) {
                        print color('bold');
                    }
                    elsif ($hash{$converted}{'Dam'}==100) {
                        print color('italic');;
                    }
                    print " [$hash{$converted}{'HP'}]! ";
                }
                else {
                    if ($hash{$converted}{'DamTaken'}==0.5) {
                        print color('bold');
                    }
                    elsif ($hash{$converted}{'Dam'}==100) {
                        print color('italic');;
                    }
                    print " [$hash{$converted}{'HP'}] ";
                }
                
                print color('reset');
            }
            elsif ($arr[$i][$j] == 2) {
                my $converted = ConvertCoordinate($i.$j);
                print color('yellow');
                if ($hash{$converted}{'HP'} <100) {
                    if ($hash{$converted}{'DamTaken'}==0.5) {
                        print color('bold');
                    }
                    elsif ($hash{$converted}{'Dam'}==100) {
                        print color('italic');
                    }
                    print " [$hash{$converted}{'HP'}]! ";
                }
                else {
                    if ($hash{$converted}{'DamTaken'}==0.5) {
                        print color('bold');
                    }
                    elsif ($hash{$converted}{'Dam'}==100) {
                        print color('italic');
                    }
                    print " [$hash{$converted}{'HP'}] ";
                }
                
                print color('reset');
            }
            else {
                print "   $arr[$i][$j]   ";
            }
            
        }
        print "\n\n\n";

    }
}

1