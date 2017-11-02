use IO::Socket::INET;
use Term::ANSIColor;

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

sub 
# my $a1 = int(rand(2));
# print "$a1\n";
# $a1 = randnum($a1);
# print "$a1\n";

    my @arr = ([0, 0, 0, 0, 0],[0, 0, 0, 0, 0],[0, 0, 0, 0, 0],[0, 0, 0, 0, 0],[0, 0, 0, 0, 0]);
    
    @arr = randnum(@arr);
    print color('bold blue');
    print "  A B C D E\n";
    print color('reset');
    for (my $i =0; $i < 5; $i++) {
        my $row = $i + 1;
        print color('bold blue');
        print "$row ";
        print color('reset');
        for (my $j = 0; $j < 5; $j++) {
            print "$arr[$i][$j] ";
        }
        print "\n";
        print color('bold blue');
    }
    

    # while(1) {
    #     print "Random number: $random_number\n";
    #     # read up to 1024 characters from the connected client
    #     my $data = "";
    #     $client_socket->recv($data, 1024);
    #     chomp($data);
    #     print "received data: $data\n";
    #     if ($data == $random_number) {
    #             print "YOU WIN. GAME OVER!\n";
    #             $data = "YOU WIN. GAME OVER!\n";
    #             $client_socket->send($data);

    #             # notify client that response has been sent
    #             shutdown($client_socket, 1);
    #             last;
    #         }
    #     elsif ($data < $random_number) {
    #         # write response data to the connected client
    #         $data = "TRY AGAIN (Hint: the correct answer is between $data - 100)\n";
    #         $client_socket->send($data);

    #     }
    #     else {
    #         $data = "TRY AGAIN (Hint: the correct answer is between 0 - $data)\n";
    #         $client_socket->send($data);
    #     }
    # }
    
    
 
    


