use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile (
    NAME        => 'Alleg',
    PREREQ_PM   => {
        enum            => 0,
        Data::Dumper    => 0,
        Clone           => 0,
    },
    VERSION     => do { my @r = (q$Name: RELEASE_1_3 $ =~ /\d+/g); sprintf '%d.%03d'.'%02d' x ($#r-1), @r},
);
