require "./utility.pl";
use IO::Socket::INET;
use Term::ANSIColor;
use Term::ANSIColor 2.00 qw(:pushpop);
use JSON;
use strict;
use Deep::Encode;
use Scalar::Util qw(looks_like_number);

use Data::Dumper;
# auto-flush on socket
$| = 1;

# create a connecting socket
    my $socket = IO::Socket::INET->new(
        PeerHost => '127.0.0.1',
        PeerPort => '9999',
        Proto => 'tcp',
    );
    die "cannot connect to the server $!\n" unless $socket;
    print "Connected to the server\n\t";

 while(1) {
    print PUSHCOLOR RED ON_GREEN "-----------------------------------------\n";
    print color('reset');
    print "\t";
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

    print "Your ships are marked by ship's HP colored ";
    print color('yellow');
    print "yellow\n";
    print color('reset');
    
    # receive a response of up to 1024 characters from server
    my $response;
    $socket->recv($response, 1024);
    my @arr = ReceiveBattleField($response);
    my $dice = "";
    $socket->recv($dice, 12);
    print "Dice result: $dice\n";
    if ($dice eq "Server turn") {
        # Receive battlefield map
        print "Server shoot for the 1st time\n";
        my $response="";
        $socket->recv($response, 1024);
        @arr = ReceiveBattleField($response);
    }
    elsif ($dice eq "Client turn") {
        # Shoot and send battlefield map
        print "Client shoot for the 1st time\n";
        @arr = ClientMove(@arr);
        my $encoded = encode_json(\@arr);
        SendBattlefield($encoded,$socket);
    }
    else {
        print "Something wrong with connecting server\n";
        last;
    }
    

    for (my $i = 1;;$i++) {
        print "-----\nLoop $i for Client \n";
        if ($dice eq "Server turn") {
            if ($i%2!=0) {
                print "Client shoot\n";
                @arr = ClientMove(@arr);
                my $encoded = encode_json(\@arr);
                SendBattlefield($encoded,$socket);

            }
            else {
                print "Server shoot\n";
                my $response="";
                $socket->recv($response, 1024);
                @arr = ReceiveBattleField($response);

            }
            
        }
        else {
            if ($i%2!=0) {
                print "Server shoot\n";
                my $response="";
                $socket->recv($response, 1024);
                @arr = ReceiveBattleField($response);

            }
            else {
                print "Client shoot\n";
                @arr = ClientMove(@arr);

                my $encoded = encode_json(\@arr);
                SendBattlefield($encoded,$socket);
                
            }
        }
        my $gameover="";
        $socket->recv($gameover, 1024);
        if ($gameover eq "Continue") {
            next;
        }
        else {
            print "$gameover\n";
            last;
        }
    
    }
last;    
}

$socket->close();

