%----------------------------------------------------------------------------%
%                              Ideje za naprej
%-----------------------------------------------------------------------(fold)

\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{izpit}[2010/10/06 Izpitne pole]

%------------------------------------------------------------------------(end)
%                       Pomozni ukazi in spremenljivke
%-----------------------------------------------------------------------(fold)

% Nalozimo pakete, ki ponujajo enostavno programiranje.
\RequirePackage{ifthen, keyval, xstring, calculator}

\newcommand\PlaceText[3]{%
\begin{tikzpicture}[remember picture,overlay]
\node[outer sep=0pt,inner sep=0pt,anchor=south west] 
  at ([xshift=#1,yshift=-#2]current page.north west) {#3};
\end{tikzpicture}%
}


% Definiramo pomozne ukaze.
\newcommand{\@ifthen}[2]{\ifthenelse{#1}{#2}{\relax}}
\newcommand{\@unless}[2]{\ifthenelse{#1}{\relax}{#2}}
\newcommand{\@blank}[1]{\equal{#1}{}}

% Zastareli ukazi
\newcommand{\@oldcommand}[2]{
  \newcommand{#1}{
    \AtEndDocument{%
      \PackageWarningNoLine{izpit}{%
        Ukaz \protect#1\space je zastarel.\MessageBreak
        Uporabite ukaz \protect#2%
      }%
    }%
    #2%
  }
}
\newcommand{\@oldoption}[2]{
  \DeclareOption{#1}{
    \AtEndDocument{%
      \PackageWarningNoLine{izpit}{%
        Možnost \protect#1\space je zastarela.\MessageBreak
        Uporabite možnost \protect#2%
      }%
    }%
    \ExecuteOptions{#2}%
  }
}
\@oldcommand{\dodatnanaloga}{\naloga*}
\@oldcommand{\glava}{\izpit}
\@oldoption{list}{arhiv}
\@oldoption{cp1250}{sumniki}

% Definiramo pomozne spremenljivke.
\newboolean{@celostranske}        % Bodo naloge celostranske?
\newboolean{@vpisnapolja}         % Naj bodo na izpitu polja za podatke?
\newboolean{@slovenski}           % Je izpit v slovenscini ali v anglescini?
\newboolean{@nadaljuj}            % Naj se števec nalog nadaljuje od prej?
\newboolean{@dodana}              % Gre naslednja naloga se na isto stran?
\newboolean{@brezpaketov}         % Ali naj ne nalozimo dodatnih paketov?
\newboolean{@sedeznired}          % Ali naj bo sedezni red natisnjen?
\newboolean{@vpisnastevilka}      % Ali naj se prikaze polje za vpisno stevilko?

\newboolean{@maturitetni}         % Naj se natisne izpit s formulami mature?

%------------------------------------------------------------------------(end)
%                                   Opcije
%-----------------------------------------------------------------------(fold)

% V osnovi imamo celostranske naloge in vpisna polja
\setboolean{@celostranske}{true}
\setboolean{@vpisnapolja}{true}
\setboolean{@maturitetni}{false}
% arhiv: naloge ena pod drugo in brez vpisnih polj
\DeclareOption{arhiv}{
  \setboolean{@celostranske}{false}
  \setboolean{@vpisnapolja}{false}
}
% izpolnjen: vpisnih polj ni, ker so ze izpolnjena
\DeclareOption{izpolnjen}{
  \setboolean{@vpisnapolja}{false}
}

% brezpaketov: neobveznih paketov ne nalozimo
\DeclareOption{brezpaketov}{\setboolean{@brezpaketov}{true}}

% Ker hocemo v osnovi velikost 11pt, moramo vse te opcije eksplicitno podati.
\def\@points{11pt}
\DeclareOption{10pt}{\def\@points{10pt}}
\DeclareOption{12pt}{\def\@points{12pt}}

% Ker nekateri nimajo podpore za unicode, omogocimo se dve stari kodni tabeli.
\def\@encoding{utf8}
\DeclareOption{sumniki}{\def\@encoding{cp1250}}
% vse ostale moznosti (fleqn, twocolumn, ...) podamo naprej v paket article
\DeclareOption*{\PassOptionsToClass{\CurrentOption}{article}}

\ProcessOptions\relax

%------------------------------------------------------------------------(end)
%                             Nalaganje paketov
%-----------------------------------------------------------------------(fold)

% Za osnovo si vzamemo article ter nalozimo pakete.
\LoadClass[\@points]{article}
\@unless{\boolean{@brezpaketov}}{
  \RequirePackage{amsfonts,amsmath}
  \RequirePackage[slovene]{babel}
  \RequirePackage[\@encoding]{inputenc}
}
\RequirePackage{geometry}
\RequirePackage{tikz}
\RequirePackage{pgfplots}
\RequirePackage{float}
\RequirePackage[gen]{eurosym}

%------------------------------------------------------------------------(end)
%                                Dimenzije
%-----------------------------------------------------------------------(fold)

\geometry{
  a4paper,
  hmargin = 25mm,
  vmargin = 15mm,
  marginparsep = 8mm
}
\parindent 1em
\pagestyle{empty}

\def\v@predizpitom{-12mm}
% presledki pred in za naslovi nalogami in podnalog
\def\v@mednalogami{2em}
\def\v@medpodnalogami{0.75em}
\def\h@zapodnalogo{0.5em}
\def\h@sirinaglave{\textwidth}
\def\h@sirinanaslova{12cm}
\def\h@sirinaucilnice{3.456cm}
\def\h@sirinaimena{6cm}
\def\h@odmiktock{5mm}
\def\v@predpraznoglavo{5mm}
\def\v@predpodnaslovom{1mm}
\def\v@predpravili{2mm}
\def\v@predimenom{6mm}
\def\v@predvpisno{6pt}
\def\x@visinavpisne{0.7}
\def\x@sirinavpisne{0.432}
\def\x@visinaocene{\x@visinavpisne}
\def\x@sirinaocene{\x@visinavpisne}
\def\x@velikostucilnice{0.15}
\def\h@velikostsedeza{3.1pt}

\def\t@imepriimek{}
\def\t@vpisnastevilka{}

%------------------------------------------------------------------------(end)
%                                Vecjezicnost
%-----------------------------------------------------------------------(fold)

% \@sloeng vrne prvi argument v slovenskih in drugega v angleskih izpitih.
\newcommand{\@sloeng}[2]{\ifthenelse{\boolean{@slovenski}}{#1}{#2}}

\newcommand{\ime@oznaka}{\@sloeng{Ime in priimek, razred}{Name and surname}}
\newcommand{\vpisna@oznaka}{\@sloeng{Vpisna \v{s}tevilka}{Student ID}}
\newcommand{\sedez@oznaka}{\@sloeng{Sede\v{z}}{Seat}}
\newcommand{\naloga@oznaka}[1]{\@sloeng{#1. naloga}{Question #1}}

\def\@gobbleminus#1{\ifx-#1\else#1\fi}
\def\@IsInteger#1{%
  TT\fi
  \ifcat_\ifnum9<1\@gobbleminus#1 _\else A\fi
}

\DeclareRobustCommand{\tocke}[1]{%
  % v count255 shranimo ostanek tock pri deljenju s 100
  \if\@IsInteger{#1}%
    \count255=#1
    \divide\count255 by 100
    \multiply\count255 by -100
    \advance\count255 by #1
  \else%
    \count255=0
  \fi
  % glede na ostanek tock pri deljenju s 100 nastavimo koncnico
  #1 \@sloeng{%
    to\v{c}k\ifcase\count255 \or a\or i\or e\or e\fi%
  }{%
    mark\ifcase\count255 s\or \else s\fi%
  }%
}

%------------------------------------------------------------------------(end)
%                             Oblikovanje glave
%-----------------------------------------------------------------------(fold)

% Nastavimo možnosti, ki jih sprejme glava.
\define@key{izpit}{anglescina}[true]{\setboolean{@slovenski}{false}}
\define@key{izpit}{nadaljuj}[true]{\setboolean{@nadaljuj}{true}}
\define@key{izpit}{brez vpisne}[true]{\setboolean{@vpisnastevilka}{false}}
\define@key{izpit}{maturitetni}[true]{\setboolean{@maturitetni}{true}}
\define@key{izpit}{sedezni red}[true]{\tikzstyle{dovoljen} = [fill=black!20]}
\define@key{izpit}{naloge}[4]{\def\stevilo@nalog{#1}}
\define@key{izpit}{ucilnica}{
  \@ifthen{\equal{#1}{JEDILNICA}}{\nastavi@ucilnico{\@jedilnica}{JEDILNICA}}
  \@ifthen{\equal{#1}{RAZRED}}{\nastavi@ucilnico{\@razred}{RAZRED}}
  \setboolean{@sedeznired}{true}
}

\define@key{izpit}{pred izpitom}[]{\def\v@predizpitom{#1}}
\define@key{izpit}{med nalogami}[]{\def\v@mednalogami{#1}}
\define@key{izpit}{med podnalogami}[]{\def\v@medpodnalogami{#1}}
\define@key{izpit}{za podnalogo}[]{\def\h@zapodnalogo{#1}}
\define@key{izpit}{sirina glave}[]{\def\h@sirinaglave{#1}}
\define@key{izpit}{sirina naslova}[]{\def\h@sirinanaslova{#1}}
\define@key{izpit}{sirina ucilnice}[]{\def\h@sirinaucilnice{#1}}
\define@key{izpit}{sirina imena}[]{\def\h@sirinaimena{#1}}
\define@key{izpit}{odmik tock}[]{\def\h@odmiktock{#1}}
\define@key{izpit}{pred prazno glavo}[]{\def\v@predpraznoglavo{#1}}
\define@key{izpit}{pred datumom}[]{\def\v@predpodnaslovom{#1}}
\define@key{izpit}{pred pravili}[]{\def\v@predpravili{#1}}
\define@key{izpit}{pred imenom}[]{\def\v@predimenom{#1}}
\define@key{izpit}{pred vpisno}[]{\def\v@predvpisno{#1}}
\define@key{izpit}{visina vpisne}[]{\def\x@visinavpisne{#1}}
\define@key{izpit}{sirina vpisne}[]{\def\x@sirinavpisne{#1}}
\define@key{izpit}{visina ocene}[]{\def\x@visinaocene{#1}}
\define@key{izpit}{sirina ocene}[]{\def\x@sirinaocene{#1}}
\define@key{izpit}{velikost ucilnice}[]{\def\x@velikostucilnice{#1}}
\define@key{izpit}{velikost sedeza}[]{\def\h@velikostsedeza{#1}}

\define@key{izpit}{ime in priimek}[]{\def\t@imepriimek{#1}}
\define@key{izpit}{vpisna stevilka}[]{\def\t@vpisnastevilka{#1}}

\newcommand{\nastavi@ucilnico}[2]{
  \def\ucilnica@polje{#1}%
  \def\ucilnica@oznaka{\sedez@oznaka}%
}

% Pripravimo spremenljivke, ki bodo shranile lastnosti glave.
\def\stevilo@nalog{4}

% Ukaz za izpis glave izpita.
\newcommand{\izpit}[4][]{%
  % Naredimo novo stran ter stevec nalog postavimo na zacetek.
  \clearpage%
  % Obravnavamo argumente, v katerih so meta-podatki o izpitu.
  \setboolean{@slovenski}{true}%
  \setboolean{@nadaljuj}{false}%
  \setboolean{@sedeznired}{false}%
  \setboolean{@vpisnastevilka}{false}%
  \setkeys{izpit}{#1}%
  \def\@naslov{#2}%
  \def\@podnaslov{#3}%
  \def\@pravila{#4}%
  % Naslednja naloga pride na isto stran kot glava
  \setboolean{@dodana}{true}%
  \@unless{\boolean{@nadaljuj}}{%
    \setcounter{naloga}{0}%
  }%
  \@natisniizpit
}

\newcommand{\@navodila}{
  \raggedright
  \textbf{\@naslov}
  \vskip \v@predpodnaslovom
  \@podnaslov
  \vskip \v@predpravili
  \small\@pravila
}

\newcommand{\@oznaka}[2]{\vbox{#1\vskip -4pt{\footnotesize #2}}}

% Natisnemo glavo izpita.
\newcommand{\@natisniizpit}{%
  \vspace*{\v@predizpitom}
  \noindent%
  \parbox[b]{\h@sirinaglave}{%
  \noindent%
  \ifthenelse{\boolean{@vpisnapolja}}{%
    \parbox[b]{\h@sirinanaslova}{%
      \@navodila
      \vskip \v@predimenom
      \begin{tikzpicture}
        \draw[very thin] (0, 0) -- (\h@sirinaimena, 0);%
        \draw[overlay] (0, 0) node[below right=0pt, inner xsep=0pt] {\footnotesize \ime@oznaka};
        \draw[overlay] (0, 0) node[above right=0pt, inner xsep=0pt] {\LARGE \t@imepriimek};
      \end{tikzpicture}
    }%
    \hfill%
    \parbox[b]{\h@sirinaucilnice}{%
      \@ifthen{\boolean{@sedeznired}}{%
        \@oznaka{\hfill\llap{\ucilnica@polje}}{\hfill\ucilnica@oznaka}%
        \vskip \v@predvpisno%
      }%
      \@ifthen{\boolean{@vpisnastevilka}}{%
        \begin{tikzpicture}
          \draw[xscale=\x@sirinavpisne, yscale=\x@visinavpisne, very thin]
            (0, 0) grid (8, 1);%
          \draw[overlay, xscale=\x@sirinavpisne] (8, 0) node[below left=0pt, inner xsep=0pt] {\footnotesize \vpisna@oznaka};
          \foreach \i in {1, ..., 8}
              \draw[xscale=\x@sirinavpisne, yscale=\x@visinavpisne] (\i - 0.5, 0.5) node {\LARGE \StrChar{\t@vpisnastevilka}{\i}};
        \end{tikzpicture}
      }%
    }%
  \@ifthen{\stevilo@nalog > -1}{%
    \def\@tempsize{3.5cm}%
    \ifcase\stevilo@nalog%
      \def\@tempsize{0.7cm}\or%
      \def\@tempsize{1.4cm}\or%
      \def\@tempsize{2.1cm}\or%
      \def\@tempsize{2.8cm}\fi%
    \rlap{\hspace{\h@odmiktock}%
      \raisebox{\@tempsize}{\vbox to 0pt{%
        \parbox[b]{\x@sirinaocene cm}{%
          \begin{tikzpicture}[xscale=\x@sirinaocene, yscale=-\x@visinaocene]
            \draw[very thin] (0, -1) grid (1, \stevilo@nalog);
            \@ifthen{\not \equal{\stevilo@nalog}{0}} {
              \foreach \naloga in {1, ..., \stevilo@nalog}
                 \draw[yshift=-1.5cm] (0, \naloga) node[left]{\small \naloga};
              \draw[very thick, yshift=-1cm] (0, \stevilo@nalog) -- (1, \stevilo@nalog);
            }
            \draw[yshift=-0.5cm] (0, \stevilo@nalog) node[left]{\small $\Sigma$};
          \end{tikzpicture}%
        }%
      }}%
    }%
  }%
  }{%
    \vskip \v@predpraznoglavo
    \@navodila
  }%
  }%
  
  \addvspace{\v@mednalogami}
  \@afterindentfalse%
  \@afterheading%

\ifthenelse{\boolean{@maturitetni}}{%
	\vskip \v@predimenom
	\begin{small}
	\textbf{Formule}\\
	$a^n+b^n=(a+b)(a^{n-1}-a^{n-2}b+ \ldots -ab^{n-2}+b^{n-1})$, če je $n$ liho naravno število\\
	$a^n+b^n=(a-b)(a^{n-1}+a^{n-2}b+ \ldots +ab^{n-2}+b^{n-1})$, če je $n \in \mathbb{N}$\\
	Evklidov in višinski izrek v pravokotnem trikotniku: $a^2=ca_1$, $b^2=cb_1$, $v_c^2=a_1b_1$\\
	Polmer trikotniku očrtanega in včrtanega kroga: $R=\frac{abc}{4S}$, $r=\frac{S}{s}$, $s=\frac{a+b+c}{2}$\\
	Kotne funkcije polovičnih kotov:\\
	$\sin \frac{x}{2}=\pm \sqrt{\frac{a-\cos x}{2}}$, $\cos \frac{x}{2}=\pm \sqrt{\frac{1+\cos x}{2}}$, $\tan \frac{x}{2}=\frac{\sin x}{1+\cos x}$\\
	Adicijski izreki:\\
	$\sin(x+y)=\sin x\cos y+\cos x\sin y$\\
	$\cos(x+y)=\cos x \cos y -\sin x \sin y$\\
	$\tan(x+y)=\frac{\tan x+\tan y}{1-\tan x\tan y}$\\
	Faktorizacija:\\
	$\sin x+\sin y=2\sin\frac{x+y}{2}\cos\frac{x-y}{2}$, $\sin x - \sin y =2\cos \frac{x+y}{2}\sin \frac{x-y}{2}$\\
	$\cos x + \cos y = 2 \cos \frac{x+y}{2}\cos \frac{x-y}{2}$, $\cos x -\cos y = -2 \sin \frac{x+y}{2}\sin \frac{x-y}{2}$\\
	$\tan x \pm \tan y = \frac{\sin(x\pm y)}{\cos x \cos y}$\\
	Razčlenitev produkta kotnih funkcij:\\
	$\sin x \sin y = -\frac{1}{2}[\cos(x+y)-\cos(x-y)]$\\
	$\cos x \cos y = \frac{1}{2}[\cos(x+y)+\cos(x-y)]$\\
	$\sin x \cos y = \frac{1}{2}[\sin(x+y)+\sin(x-y)]$\\
	Razdalja točke $T(x_0,y_0)$ do premice $p: ax+by-c=0$:\\
	$d(T_0,p)=|\frac{ax_0+by_0-c}{\sqrt{a^2+b^2}}|$\\
	Ploščina trikotnika z oglišči $A(x_1,y_1), B(x_2,y_2),C(x_3,y_3)$:\\
	$S= \frac{1}{2}|(x_2-x_1)(y_3-y_1)-(x_3-x_1)(y_2-y_1)|$\\
	Elipsa: $e^2=a^2-b^2, \varepsilon = \frac{e}{a}, a>b$\\
	Hiperbola: $e^2=a^2+b^2, \varepsilon = \frac{e}{a}$. $a$ je realna polos\\
	Parabola: $y^2=2px$, gorišče $G(\frac{p}{2},0)$\\
	Kompozitum funkcij: $(g \circ f)(x)=g(f(x))$\\
	Bernoullijeva formula: $P(n,p,k)=\binom{n}{k}p^k(1-p)^{n-k}$\\
	Integral: $\int \frac{dx}{x^2+a^2}=\frac{1}{a} \arctan \frac{x}{a}+C$\\
	\end{small}
	}

}

%------------------------------------------------------------------------(end)
%                             Oblikovanje nalog
%-----------------------------------------------------------------------(fold)

% Nastavimo stevec nalog.
\newcounter{naloga}

% Oznaka naloge
\newcommand{\oznakanaloge}{%
  \naloga@oznaka{\arabic{naloga}}%
}

% Oznaka tock naloge
\newcommand{\oznakatocknaloge}[1]{%
  \ (#1)%
}

% Oblika naloge
\newcommand{\oblikanaloge}[2]{%
  \addvspace{\v@mednalogami}%
  \filbreak%
  \noindent%
  \textbf{#1#2}%
  \par\addvspace{\v@medpodnalogami}%
  \@afterindentfalse%
  \@afterheading%
}

% Ukaz za izpis nalog, ki je skupen vsem oblikam nalog.
% Kot neobvezni argument sprejme stevilo tock.
\newcommand{\naloga@novastran}[1][]{%
  % Najprej povecamo stevec naloge.
  \stepcounter{naloga}%
  % Ce so naloge celostranske in naloga ni dodana, naredimo novo stran.
  \@ifthen{\boolean{@celostranske} \and \not \boolean{@dodana}}{\newpage}%
  % Ce ne bomo rekli eksplicitno, naslednja naloga ne bo dodana na isto stran.
  \setboolean{@dodana}{false}%
  
  % Sedaj izpisemo nalogo.
  \oblikanaloge{%
    % Izpisemo oznako naloge.
    \oznakanaloge%
  }{%
    % K oznaki dodamo se stevilo tock, ce je le vneseno.
    \@unless{\@blank{#1}}{%
      \oznakatocknaloge{#1}%
    }%
  }%
}

% Ce je naloga dodatna, je ne dodamo na novo stran. Ostalo ostane enako.
\newcommand{\naloga@istastran}{%
  \setboolean{@dodana}{true}%
  \naloga%
}

\newcommand{\naloga}{\@ifstar{\naloga@istastran}{\naloga@novastran}}

%------------------------------------------------------------------------(end)
%                             Oblikovanje podnalog
%-----------------------------------------------------------------------(fold)

% Nastavimo stevec podnalog, ki se resetira z vsako nalogo.
\newcounter{podnaloga}[naloga]

% Oznaka naloge
\newcommand{\oznakapodnaloge}{%
  \alph{podnaloga})%
}

% Oznaka tock podnaloge
\newcommand{\oznakatockpodnaloge}[1]{%
  \ (#1)%
}

% Oblika podnaloge
\newcommand{\oblikapodnaloge}[2]{%
  \addvspace{\v@medpodnalogami}%
  \vfil\penalty-150\vfilneg\par%
  \noindent%
  \textbf{#1#2}%
  \hspace{\h@zapodnalogo}%
}

% Ukaz za izpis nalog, ki je skupen vsem oblikam podnalog.
% Kot neobvezni argument sprejme stevilo tock.
\newcommand{\podnaloga}[1][]{%
  % Najprej povecamo stevec podnaloge.
  \stepcounter{podnaloga}%
  
  % Sedaj izpisemo nalogo.
  \oblikapodnaloge{%
    % Izpisemo oznako naloge.
    \oznakapodnaloge%
  }{%
    % K oznaki dodamo se stevilo tock, ce je le vneseno.
    \@unless{\@blank{#1}}{%
      \oznakatockpodnaloge{#1}%
    }%
  }%
  % Ker znajo biti za ukazom se kaksni presledki, jih ignoriramo.
  \ignorespaces%
}

\newcommand{\dodatek}[1]{%
  \@ifthen{\boolean{@celostranske}}{#1}%
}

% Ukaz za prostor pod nalogo. Velikosti prostorov na strani so enakomerne.
\newcommand{\prostor}[1][1]{%
  % Prostor damo le, ce so naloge celostranske.
  \dodatek{\vspace{\stretch{#1}}}
}

%------------------------------------------------------------------------(end)
%                                   Slike
%-----------------------------------------------------------------------(fold)

\tikzstyle{dovoljen} = []
\tikzstyle{sedez} = [circle, draw, ultra thin, inner sep=0pt, minimum width=\h@velikostsedeza]
\tikzstyle{kateder} = [ultra thin]
\tikzstyle{ucilnica} = [scale=\x@velikostucilnice]

\newcommand{\@sedez}[3][]{\draw[#1](#3, #2)}
\newcommand{\@sedezi}[4][\@sedez]{
  \foreach \i in {#2} {
    \foreach \j in {#3} {#1{\i}{\j} node[sedez] {};}
    \foreach \j in {#4} {#1{\i}{\j} node[sedez, dovoljen] {};}
  }
}

\newcommand{\@jedilnica}{%
  \begin{tikzpicture}[ucilnica]
    \draw[kateder] (-3.5,-1) rectangle (-1.5,-15);
    \@sedezi{-1,...,-15}{}{-4}
    \@sedezi{-1,...,-15}{}{-1}
    \draw[kateder] (3.5,-1) rectangle (5.5,-15);
    \@sedezi{-1,...,-15}{}{3}
    \@sedezi{-1,...,-15}{}{6}
  \end{tikzpicture}%
}


\newcommand{\@razred}{%
  \begin{tikzpicture}[ucilnica]
    \draw[kateder] (-5.5,0) rectangle (-2.5,1);
    \@sedezi{-1,-2}{}{-8,-7}
    \@sedezi{-4,-5}{}{-8,-7}
    \@sedezi{-7,-8}{}{-8,-7}
    \@sedezi{-10,-11}{}{-8,-7}
    \@sedezi{-1,-2}{}{-5,...,-2}
    \@sedezi{-4,-5}{}{-5,...,-2}
    \@sedezi{-7,-8}{}{-5,...,-2}
    \@sedezi{-10,-11}{}{-5,...,-2}
    \@sedezi{-1,-2}{}{0,1}
    \@sedezi{-4,-5}{}{0,1}
    \@sedezi{-7,-8}{}{0,1}
    \@sedezi{-10,-11}{}{0,1}
  \end{tikzpicture}%
}

%------------------------------------------------------------------------(end)
