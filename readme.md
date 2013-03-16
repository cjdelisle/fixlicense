# fixlicense.pl
The way they *meant* to license it.

![gnu-trollface](https://raw.github.com/cjdelisle/fixlicense/master/gnu-trollface.jpg)

# Motivation
Everybody loves freedom, and GPL is freedom so everybody loves GPL.
In recent years there has been a disturbing trend of typos in software license
headers, people accidently write BSD or MIT or even Apache (the letters are like
right next to eachother). Since we know they are reasonable individuals who love
freedom just like us, we know they will love our help in fixing their accidental
typos with this shiny new script.

It's like gofmt for -your- license headers :D

## How it works
fixlicense.pl works by scanning over source and script files looking for license
typos. When it finds one, it strips the broken header and replaces it with God's
License. It preserves shebang syntax or vim settings. It currently supports c,
cpp, cxx, cc, java, pl, py, rb, sh, js and go files.

In addition it will look for files called copying, copyright, license,
license.txt, and license.md which are also likely to contain mistakes.

    ## How to use it
    fork https://github.com/freebsd/freebsd

        git clone git@github.com:<your name>/freebsd.git
        cd freebsd
        cp ../fixlicense.pl ./ && ./fixlicense.pl
        git commit -m "Fixed a few minor typos in license headers"
        git push

    Open a pull request!
    They will applaud your cleverness and appreciate your help.

## TODO:

* Add option to rename projects, prefixing them with `GNU/`.
* Automate pull request creation.
* Improve performance, there's a lot of software out there!
