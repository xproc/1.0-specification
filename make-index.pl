#!/usr/bin/perl -- # -*- Perl -*-

use strict;
use English;

# Hack hack hack

print <<EOF1;
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<title>XProc 2.0: An XML Pipeline Language</title>
</head>
<body>
<h1>XProc 2.0: An XML Pipeline Language</h1>

<p>This site hosts editor's drafts of
<cite>XProc 2.0: An XML Pipeline Language</cite> baked fresh
automagically by <a href="http://travis-ci.org/">Travis CI</a> after
every commit.</p>
EOF1

my @branches = ();
opendir(DIR, "langspec");
while (readdir(DIR)) {
    next if /^\.\.?$/;
    next if ! -d "langspec/$_";
    push (@branches, $_) unless $_ eq 'xproc20';
}
closedir(DIR);

print "<dl>\n";
foreach my $branch ("xproc20", sort { $a cmp $b } @branches) {
    my $fn = "langspec/$branch/head/xproc20/index.html";
    my $date = pubdate($fn);
    print "<dt>The <em>$branch</em> branch, $date:</dt>\n";
    print "<dd>\n";
    &showspec($branch);
    print "</dd>\n";
}
print "</dl>\n";

print <<EOF3;
<p>Remember: these documents are editor's drafts with no normative
standing.</p>

<p>If you have a question or comment about these documents, please
raise it as
<a href="https://github.com/xproc/specification/issues">an issue</a>
on the specification repository.</p>

</body>
</html>
EOF3

exit 0;

sub pubdate {
    my $spec = shift;
    open (F, $spec) || return "date unknown";
    read (F, $_, 4096);
    close (F);
    s/^.*?<h2>(.*?)<\/h2>.*$/$1/s;

    if (/\d+\s+\S+\s+\d+/) {
        $_ = $MATCH;
    } else {
        $_ = "";
    }

    return $_;
}

sub title {
    my $spec = shift;
    open (F, $spec) || return "date unknown";
    read (F, $_, 4096);
    close (F);
    s/^.*?<div class=.title.>(.*?)<\/div>.*$/$1/s;
    return $_;
}

sub showspec {
    my $branch = shift;
    print "<ul>\n";
    foreach my $name ("xproc20", "xproc20-steps", "ns-p", "ns-c", "ns-err") {
        my $href = "langspec/$branch/head/$name/";
        my $fn = "$href/index.html";
        my $title = title($fn);
        print "<li><a href=\"$href\">$title</a></li>\n";
    }
    print "</ul>\n";
}
