Function FixText(s As String) As String

    ' ================================================================
    ' Corrige e normaliza texto com encoding corrompido
    ' Baseado em mapeamento real dos dados
    ' ORDEM IMPORTA: sequencias maiores primeiro
    ' NULL = substitui por "" (remove)
    ' ================================================================

    Dim r As String
    r = s

    ' ----------------------------------------------------------------
    ' 1) 8 CHARS - tripla codificacao
    ' ----------------------------------------------------------------
    ' \u00c3\u0083\u00c2\u0083\u00c3\u0082\u00c2\u0089 -> E
    r = Replace(r, ChrW(&HC3) & ChrW(&H83) & ChrW(&HC2) & ChrW(&H83) & _
                   ChrW(&HC3) & ChrW(&H82) & ChrW(&HC2) & ChrW(&H89), "E")

    ' ----------------------------------------------------------------
    ' 2) 4 CHARS - dupla codificacao e sequencias especiais
    ' ----------------------------------------------------------------
    r = Replace(r, ChrW(&HC3) & ChrW(&H83) & ChrW(&HC2) & ChrW(&H81), "A")   ' duplo Á
    r = Replace(r, ChrW(&HC3) & ChrW(&H83) & ChrW(&HC2) & ChrW(&H83), "A")   ' duplo Ã
    r = Replace(r, ChrW(&HC3) & ChrW(&H83) & ChrW(&HC2) & ChrW(&H87), "C")   ' duplo Ç
    r = Replace(r, ChrW(&HC3) & ChrW(&H83) & ChrW(&HC2) & ChrW(&H89), "E")   ' duplo É
    r = Replace(r, ChrW(&HC3) & ChrW(&H83) & ChrW(&HC2) & ChrW(&H9A), "U")   ' duplo Ú
    r = Replace(r, ChrW(&HC3) & ChrW(&HA7) & ChrW(&HC3) & ChrW(&H39C), "O")  ' çÃΜ -> O
    r = Replace(r, ChrW(&HC3) & ChrW(&H87) & ChrW(&HC3) & ChrW(&H83), "CA")  ' ÇÃ -> CA

    ' emoji / sequencia com variation selector
    r = Replace(r, ChrW(&H27A1) & ChrW(&HFE0F), "->")     ' -> (seta direita + VS)
    r = Replace(r, ChrW(&HD83D) & ChrW(&HDC4D), "")       ' 👍 emoji -> remove

    ' sequencias com EOT (U+0004)
    r = Replace(r, ChrW(&H1B0) & ChrW(&H4), "")           ' ư + EOT -> remove
    r = Replace(r, ChrW(&H1B1) & ChrW(&H4), "")           ' Ʊ + EOT -> remove

    ' ----------------------------------------------------------------
    ' 3) 3 CHARS
    ' ----------------------------------------------------------------
    r = Replace(r, ChrW(&HE2) & ChrW(&H80) & ChrW(&H8A), "")  ' hair space -> remove
    r = Replace(r, ChrW(&HE2) & ChrW(&H80) & ChrW(&H8B), "")  ' zero width space -> remove
    r = Replace(r, ChrW(&H87) & ChrW(&HC3) & ChrW(&H83), "A") ' \u0087\u00c3\u0083 -> A

    ' ----------------------------------------------------------------
    ' 4) 2 CHARS - UTF-8 lido como Latin-1 (bloco C3)
    ' ----------------------------------------------------------------
    r = Replace(r, ChrW(&HC3) & ChrW(&H80), "A")   ' À -> A
    r = Replace(r, ChrW(&HC3) & ChrW(&H81), "A")   ' Á -> A
    r = Replace(r, ChrW(&HC3) & ChrW(&H82), "A")   ' Â -> A
    r = Replace(r, ChrW(&HC3) & ChrW(&H83), "A")   ' Ã -> A
    r = Replace(r, ChrW(&HC3) & ChrW(&H84), "A")   ' Ä -> A
    r = Replace(r, ChrW(&HC3) & ChrW(&H85), "A")   ' Å -> A
    r = Replace(r, ChrW(&HC3) & ChrW(&H86), "AE")  ' Æ -> AE
    r = Replace(r, ChrW(&HC3) & ChrW(&H87), "C")   ' Ç -> C
    r = Replace(r, ChrW(&HC3) & ChrW(&H88), "E")   ' È -> E
    r = Replace(r, ChrW(&HC3) & ChrW(&H89), "E")   ' É -> E
    r = Replace(r, ChrW(&HC3) & ChrW(&H8A), "E")   ' Ê -> E
    r = Replace(r, ChrW(&HC3) & ChrW(&H8B), "E")   ' Ë -> E
    r = Replace(r, ChrW(&HC3) & ChrW(&H8C), "I")   ' Ì -> I
    r = Replace(r, ChrW(&HC3) & ChrW(&H8D), "I")   ' Í -> I
    r = Replace(r, ChrW(&HC3) & ChrW(&H8E), "I")   ' Î -> I
    r = Replace(r, ChrW(&HC3) & ChrW(&H8F), "I")   ' Ï -> I
    r = Replace(r, ChrW(&HC3) & ChrW(&H90), "D")   ' Ð -> D
    r = Replace(r, ChrW(&HC3) & ChrW(&H91), "N")   ' Ñ -> N
    r = Replace(r, ChrW(&HC3) & ChrW(&H92), "O")   ' Ò -> O
    r = Replace(r, ChrW(&HC3) & ChrW(&H93), "O")   ' Ó -> O
    r = Replace(r, ChrW(&HC3) & ChrW(&H94), "O")   ' Ô -> O
    r = Replace(r, ChrW(&HC3) & ChrW(&H95), "O")   ' Õ -> O
    r = Replace(r, ChrW(&HC3) & ChrW(&H96), "O")   ' Ö -> O
    r = Replace(r, ChrW(&HC3) & ChrW(&H97), "x")   ' × -> x
    r = Replace(r, ChrW(&HC3) & ChrW(&H98), "O")   ' Ø -> O
    r = Replace(r, ChrW(&HC3) & ChrW(&H99), "U")   ' Ù -> U
    r = Replace(r, ChrW(&HC3) & ChrW(&H9A), "U")   ' Ú -> U
    r = Replace(r, ChrW(&HC3) & ChrW(&H9B), "U")   ' Û -> U
    r = Replace(r, ChrW(&HC3) & ChrW(&H9C), "U")   ' Ü -> U
    r = Replace(r, ChrW(&HC3) & ChrW(&H9D), "Y")   ' Ý -> Y
    r = Replace(r, ChrW(&HC3) & ChrW(&H9E), "TH")  ' Þ -> TH
    r = Replace(r, ChrW(&HC3) & ChrW(&H9F), "ss")  ' ß -> ss
    r = Replace(r, ChrW(&HC3) & ChrW(&HA0), "A")   ' à -> A
    r = Replace(r, ChrW(&HC3) & ChrW(&HA1), "A")   ' á -> A
    r = Replace(r, ChrW(&HC3) & ChrW(&HA2), "A")   ' â -> A
    r = Replace(r, ChrW(&HC3) & ChrW(&HA3), "A")   ' ã -> A
    r = Replace(r, ChrW(&HC3) & ChrW(&HA4), "A")   ' ä -> A
    r = Replace(r, ChrW(&HC3) & ChrW(&HA5), "A")   ' å -> A
    r = Replace(r, ChrW(&HC3) & ChrW(&HA6), "AE")  ' æ -> AE
    r = Replace(r, ChrW(&HC3) & ChrW(&HA7), "C")   ' ç -> C
    r = Replace(r, ChrW(&HC3) & ChrW(&HA8), "E")   ' è -> E
    r = Replace(r, ChrW(&HC3) & ChrW(&HA9), "E")   ' é -> E
    r = Replace(r, ChrW(&HC3) & ChrW(&HAA), "E")   ' ê -> E
    r = Replace(r, ChrW(&HC3) & ChrW(&HAB), "E")   ' ë -> E
    r = Replace(r, ChrW(&HC3) & ChrW(&HAC), "I")   ' ì -> I
    r = Replace(r, ChrW(&HC3) & ChrW(&HAD), "I")   ' í -> I
    r = Replace(r, ChrW(&HC3) & ChrW(&HAE), "I")   ' î -> I
    r = Replace(r, ChrW(&HC3) & ChrW(&HAF), "I")   ' ï -> I
    r = Replace(r, ChrW(&HC3) & ChrW(&HB0), "d")   ' ð -> d
    r = Replace(r, ChrW(&HC3) & ChrW(&HB1), "N")   ' ñ -> N
    r = Replace(r, ChrW(&HC3) & ChrW(&HB2), "O")   ' ò -> O
    r = Replace(r, ChrW(&HC3) & ChrW(&HB3), "O")   ' ó -> O
    r = Replace(r, ChrW(&HC3) & ChrW(&HB4), "O")   ' ô -> O
    r = Replace(r, ChrW(&HC3) & ChrW(&HB5), "O")   ' õ -> O
    r = Replace(r, ChrW(&HC3) & ChrW(&HB6), "O")   ' ö -> O
    r = Replace(r, ChrW(&HC3) & ChrW(&HB7), "/")   ' ÷ -> /
    r = Replace(r, ChrW(&HC3) & ChrW(&HB8), "O")   ' ø -> O
    r = Replace(r, ChrW(&HC3) & ChrW(&HB9), "U")   ' ù -> U
    r = Replace(r, ChrW(&HC3) & ChrW(&HBA), "P")   ' º -> P (conforme lista)
    r = Replace(r, ChrW(&HC3) & ChrW(&HBB), "U")   ' û -> U
    r = Replace(r, ChrW(&HC3) & ChrW(&HBC), "U")   ' ü -> U
    r = Replace(r, ChrW(&HC3) & ChrW(&HBD), "Y")   ' ý -> Y
    r = Replace(r, ChrW(&HC3) & ChrW(&HBE), "th")  ' þ -> th
    r = Replace(r, ChrW(&HC3) & ChrW(&HBF), "Y")   ' ÿ -> Y

    ' Bloco C2 (caracteres especiais Latin-1)
    r = Replace(r, ChrW(&HC2) & ChrW(&HA0), " ")   ' non-breaking space -> espaco

    ' Sequencias mistas
    r = Replace(r, ChrW(&HC3) & ChrW(&H2030), "E") ' Ã‰ (Win1252 mix) -> E
    r = Replace(r, ChrW(&HC7) & ChrW(&H87), "C")   ' Ç variante -> C
    r = Replace(r, ChrW(&HCA) & ChrW(&H8A), "E")   ' Ê variante -> E
    r = Replace(r, ChrW(&HE3) & ChrW(&H81), "A")   ' sequencia japonesa -> A
    r = Replace(r, ChrW(&HE3) & ChrW(&H95), "O")   ' sequencia japonesa -> O
    r = Replace(r, ChrW(&H39C) & ChrW(&H395), "ME") ' ΜΕ (grego) -> ME
    r = Replace(r, ChrW(&HC1) & ChrW(&H81), "A")   ' Á+U+0081 -> A

    ' ----------------------------------------------------------------
    ' 5) 1 CHAR
    ' ----------------------------------------------------------------

    ' Controles ASCII -> remove
    r = Replace(r, ChrW(&H1), "")    ' SOH
    r = Replace(r, ChrW(&H4), "")    ' EOT
    r = Replace(r, ChrW(&H6), "I")   ' ACK -> I (conforme lista)
    r = Replace(r, ChrW(&H13), "")   ' DC3
    r = Replace(r, ChrW(&H14), "")   ' DC4
    r = Replace(r, ChrW(&H1A), "")   ' SUB
    r = Replace(r, ChrW(&H1C), "")   ' FS
    r = Replace(r, ChrW(&H1D), "")   ' GS
    r = Replace(r, ChrW(&H7F), "")   ' DEL
    r = Replace(r, ChrW(&H8D), "")   ' reverse line feed
    r = Replace(r, ChrW(&H95), "")   ' bullet W1252 -> remove

    ' Windows-1252 (0x80-0x9F interpretados como Unicode)
    r = Replace(r, ChrW(&H92), "'")       ' aspa simples direita
    r = Replace(r, ChrW(&H93), Chr(34))   ' aspa dupla esquerda
    r = Replace(r, ChrW(&H94), Chr(34))   ' aspa dupla direita
    r = Replace(r, ChrW(&H96), " ")       ' en dash W1252 -> espaco
    r = Replace(r, ChrW(&H97), "-")       ' em dash W1252 -> hifen

    ' Ã sozinho (nao casou com nenhuma sequencia acima)
    r = Replace(r, ChrW(&HC3), "A")

    ' Latin estendido
    r = Replace(r, ChrW(&H157), "R")   ' ŗ -> R
    r = Replace(r, ChrW(&H158), "R")   ' Ř -> R
    r = Replace(r, ChrW(&H17D), "'")   ' Ž -> ' (conforme lista)
    r = Replace(r, ChrW(&H203), "A")   ' ȃ -> A

    ' Diacriticos combinantes -> remove (ou substitui)
    r = Replace(r, ChrW(&H300), "")    ' grave combinante
    r = Replace(r, ChrW(&H301), "")    ' agudo combinante
    r = Replace(r, ChrW(&H302), "")    ' circunflexo combinante
    r = Replace(r, ChrW(&H303), "")    ' til combinante
    r = Replace(r, ChrW(&H308), " ")   ' trema combinante -> espaco
    r = Replace(r, ChrW(&H30A), "º")   ' anel combinante -> ordinal
    r = Replace(r, ChrW(&H327), "")    ' cedilha combinante -> remove

    ' Letras gregas usadas como texto
    r = Replace(r, ChrW(&H3B3), "g")   ' γ -> g
    r = Replace(r, ChrW(&H3B7), "N")   ' η -> N
    r = Replace(r, ChrW(&H3BF), "O")   ' ο -> O

    ' Cirílico
    r = Replace(r, ChrW(&H438), "I")   ' и -> I

    ' Espacos Unicode -> espaco simples
    r = Replace(r, ChrW(&H2002), " ")  ' en space
    r = Replace(r, ChrW(&H2003), " ")  ' em space
    r = Replace(r, ChrW(&H2006), " ")  ' six-per-em space
    r = Replace(r, ChrW(&H2009), " ")  ' thin space
    r = Replace(r, ChrW(&H200B), " ")  ' zero width space
    r = Replace(r, ChrW(&H200D), "")   ' zero width joiner -> remove
    r = Replace(r, ChrW(&H200E), " ")  ' LTR mark -> espaco
    r = Replace(r, ChrW(&H202F), " ")  ' narrow no-break space

    ' Pontuacao tipografica
    r = Replace(r, ChrW(&H2010), "-")       ' hifen tipografico
    r = Replace(r, ChrW(&H2011), "-")       ' hifen nao-separavel
    r = Replace(r, ChrW(&H2013), "")        ' en dash -> remove
    r = Replace(r, ChrW(&H2014), "-")       ' em dash -> hifen
    r = Replace(r, ChrW(&H2018), "'")       ' aspa simples esquerda
    r = Replace(r, ChrW(&H2019), "'")       ' aspa simples direita
    r = Replace(r, ChrW(&H201C), Chr(34))   ' aspa dupla esquerda
    r = Replace(r, ChrW(&H201D), Chr(34))   ' aspa dupla direita
    r = Replace(r, ChrW(&H2022), ".")       ' bullet -> ponto
    r = Replace(r, ChrW(&H2026), "..")      ' reticencias -> ..
    r = Replace(r, ChrW(&H2032), "'")       ' prime -> aspa
    r = Replace(r, ChrW(&H2039), "")        ' < angular -> remove
    r = Replace(r, ChrW(&H2044), "/")       ' fracao -> /

    ' Moeda / simbolos
    r = Replace(r, ChrW(&H20AC), "€")       ' euro
    r = Replace(r, ChrW(&H2116), "N°")      ' numero
    r = Replace(r, ChrW(&H2122), "")        ' trademark -> remove
    r = Replace(r, ChrW(&H2153), "1/3")     ' um terco

    ' Matematica
    r = Replace(r, ChrW(&H2193), "")        ' seta para baixo -> remove
    r = Replace(r, ChrW(&H2212), "-")       ' sinal de menos
    r = Replace(r, ChrW(&H221A), "v")       ' raiz quadrada -> v
    r = Replace(r, ChrW(&H2234), "")        ' portanto -> remove
    r = Replace(r, ChrW(&H2248), "=")       ' aproximadamente igual
    r = Replace(r, ChrW(&H2260), "!")       ' diferente -> !
    r = Replace(r, ChrW(&H2264), "<=")      ' menor ou igual
    r = Replace(r, ChrW(&H2265), ">=")      ' maior ou igual
    r = Replace(r, ChrW(&H22C5), " ")       ' operador ponto -> espaco

    ' Box drawing / misc
    r = Replace(r, ChrW(&H2550), "")        ' box drawing -> remove
    r = Replace(r, ChrW(&H25CF), "")        ' circulo preenchido -> remove
    r = Replace(r, ChrW(&H25E6), "")        ' bullet branco -> remove
    r = Replace(r, ChrW(&H2663), "")        ' naipe paus -> remove

    ' Private use / BOM
    r = Replace(r, ChrW(&HE016), "")        ' private use -> remove
    r = Replace(r, ChrW(&HFEFF), "")        ' BOM -> remove

    FixText = r

End Function
