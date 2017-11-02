require "./utility.pl";
use IO::Socket::INET;
use Term::ANSIColor;
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
    print "Connected to the server\n";

 while(1) {
    
    # receive a response of up to 1024 characters from server
    my $response;
    $socket->recv($response, 1024);
    my @arr = ReceiveBattleField($response);

    my $result = "";
    $socket->recv($result, 11);
    print "Dice result: $result\nokie\n";
    if ($result eq "Server turn") {
        # Receive battlefield map
        print "Server shoot for the 1st time\n";
        my $response="";
        $socket->recv($response, 1024);
        @arr = ReceiveBattleField($response);
    }
    elsif ($result eq "Client turn") {
        # Shoot and send battlefield map
        print "Client shoot for the 1st time\n";
        @arr = ClientMove(@arr);
        my $encoded = encode_json(\@arr);
        SendBattlefield($encoded,$socket);
    }
    else {
        my $result = "";
        $socket->recv($result, 11);
    }
    

    for (my $i = 1;;$i++) {
        print "-----\nLoop $i for Client \n";
        if ($result eq "Server turn") {
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
