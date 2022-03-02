#perlbrew install  perl-5.25.11
#perlbrew switch  perl-5.25.11
#cpanm install MIME::Lite
#cpanm install URI::Escape
#cpanm install Template
#cpanm install Template::Config
#cpanm install Getopt::Long
use MIME::Lite;
use URI::Escape;
use Template;
use Template::Config;
use Getopt::Long;

my ($template_dir,$email,$username,$html,$text,$subject,$from);

GetOptions ( 'templatedir|T=s'=>\$template_dir,'email|E=s'=>\$email,'username|U=s'=>\$username,'subject|S=s'=>\$subject,'from|f=s'=>\$from) ;
my $username_url = uri_escape($username) ;
if (!defined $subject) {
  $subject='Please help support the Archive'
}
if (!defined $from) {
  $from='Archive of Our Own <do-not-reply@archiveofourown.org>'
}

my $vars   = {
       email        => $email ,
       username     => $username ,
       username_url => $username_url,
     } ;

my $msg = MIME::Lite->new
(
  Subject => "$subject",
  From    => "$from",
  To      => "$email",
  Type    => 'multipart/alternative',
);

my $tt = Template->new( EVAL_PERL => 1,INCLUDE_PATH =>$template_dir );
if (!$tt->process('email.html', $vars,\$html) ) {
   print "Skiping $username\n" ;
   exit 1;
  }
if (!$tt->process('email.text', $vars,\$text) ) {
   print "Skiping $username\n" ;
   exit 1;
  }

$msg->attach(
        Type     => 'TEXT',
        Data     => $text );


$msg->attach(
  Type => 'text/html',
  Data    => $html);

$msg->send();
