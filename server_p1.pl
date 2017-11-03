require "./utility.pl";
use IO::Socket::INET;
use JSON;
use Storable;
use Data::Dump qw(dump);
use Term::ANSIColor 2.00 qw(:pushpop);
use JSON::XS qw(encode_json decode_json);
use File::Slurp qw(read_file write_file);

# auto-flush on socket
$| = 1;
 
# creating a listening socket
my $socket = new IO::Socket::INET (
    LocalHost => '127.0.0.1',
    LocalPort => '9999',
    Proto => 'tcp',
    Listen => 5,
    Reuse => 1
);
die "cannot create socket $!\n" unless $socket;
print "server waiting for client connection on port 7777\n";


while(1)
{
    # waiting for a new client connection
    my $client_socket = $socket->accept();
    # get information about a newly connected client
    my $client_address = $client_socket->peerhost();
    my $client_port = $client_socket->peerport();
    print "connection from $client_address:$client_port\n\t";

    print PUSHCOLOR RED ON_GREEN "-----------------------------------------";
    print color('reset');
    print "\n\t";
    print PUSHCOLOR RED ON_GREEN " WELCOME TO BATTLE SHIP GAME VERSION 1.0 \n";
    print color('reset');
    print "\t";
    print PUSHCOLOR RED ON_GREEN "-----------------------------------------\n";
    print color('reset');
    print UNDERLINE "\nInstruction:\n\n";
    print color('reset');
    print ITALIC BRIGHT_YELLOW;
    print "\t1. Choose coordinate on the map to move or to shoot (for ex. : 1A, 2B, 3C)\n";
    print "\t2. Each team will have 5 ships. The one that kills all the other team's ships are the winner\n";
    print "\t3. If you have any bugs with our app, please contact with this email: peterphan_1996\@live.com\n\n";
    print color('reset');
    print "***[NOTE]: You can shoot your own ships so be careful. You can even standstill if you input the same coordinate as your chosen ship be at\n\n\n";
    our @arr = ([0, 0, 0, 0, 0],[0, 0, 0, 0, 0],[0, 0, 0, 0, 0],[0, 0, 0, 0, 0],[0, 0, 0, 0, 0]);
    our %hash = ('okay' => 1);

    @arr = randnum(@arr);
    GenerateHash();
    CreateFile();
    print Dumper(\%hash);

    print "Your ships are marked by ship's HP colored ";
    print color('red');
    print "red\n";
    print color('reset');
    my $encoded = encode_json(\@arr);
    SendBattlefield($encoded,$client_socket);

    BattlefieldDisplay(@arr);
 
    my $dice = "";
    $dice = ThrowDie();
    print "Dice result: $dice\n";
    $client_socket->send($dice);
    if ($dice eq "Server turn") {
        # Shoot and send battlefield map
        print "Server shoot for the 1st time\n";
        @arr = ServerMove(@arr);
        my $encoded = encode_json(\@arr);
        SendBattlefield($encoded,$client_socket);

    }
    elsif ($dice eq "Client turn") {
        print "Client shoot for the 1st time\n";
        my $response="";
        $client_socket->recv($response, 1024);
        @arr = ReceiveBattleField($response);
        
    }
    

    for (my $i = 1;;$i++) {
        print "-----\nLoop $i for Server \n";
        if ($dice eq "Server turn") {
            if ($i%2!=0) {
                print "Client shoot\n";
                
                my $response="";
                $client_socket->recv($response, 1024);
                @arr = ReceiveBattleField($response);
                               
            }
            else {
                print "Server shoot\n";
                @arr = ServerMove(@arr);  
                my $encoded = encode_json(\@arr);
                SendBattlefield($encoded,$client_socket);
                
            }
            
        }
        else {
            if ($i%2!=0) {
                print "Server shoot\n";
                @arr = ServerMove(@arr);
                my $encoded = encode_json(\@arr);
                SendBattlefield($encoded,$client_socket);

            }
            else {
                print "Client shoot\n";
                my $response="";
                $client_socket->recv($response, 1024);
                @arr = ReceiveBattleField($response);
                
            }
            
        }
        my $endgame = CheckEndGame(@arr);
        if ($endgame eq "Continue") {
            $client_socket->send($endgame);
            next;
        }
        else {
            print "$endgame";
            $client_socket->send($endgame);
            last;
        }
    }
    shutdown($client_socket, 1);
 
    
}
 
$socket->close();

sub GenerateHash {
    my $extradamserver = 1;
    my $extrashieldclient = 1;
    my $extradamclient = 1;
    my $extrashieldserver = 1;
    for (my $i =0; $i < 5; $i++) {     
        for (my $j = 0; $j < 5; $j++) {
            if (($arr[$i][$j] == 1) || ($arr[$i][$j] == 2)) {
                my $join = $i . $j;
                my $converted = "";
                $converted = ConvertCoordinate($join);
                if ($extradamserver == 1 && $arr[$i][$j] == 1) {
                    $hash{$converted} = {'HP' => 100, 'Dam' => 100, 'DamTaken' => 1};
                    $extradamserver++;
                }
                elsif ($extrashieldserver == 1 && $arr[$i][$j] == 1) {
                    $hash{$converted} = {'HP' => 100, 'Dam' => 50, 'DamTaken' => 0.5};
                    $extrashieldserver++;
                }
                elsif ($extrashieldclient == 1 && $arr[$i][$j] == 2) {
                    $hash{$converted} = {'HP' => 100, 'Dam' => 50, 'DamTaken' => 0.5};
                    $extrashieldclient++;
                }
                elsif ($extradamclient == 1 && $arr[$i][$j] == 2) {
                    $hash{$converted} = {'HP' => 100, 'Dam' => 100, 'DamTaken' => 1};
                    $extradamclient++
                }
                else {
                    $hash{$converted} = {'HP' => 100, 'Dam' => 50, 'DamTaken' => 1};
                }
            }
        }
    }
}

sub CreateFile {
    my $json = encode_json \%hash;
    write_file('dump.txt', { binmode => ':raw' }, $json);
}