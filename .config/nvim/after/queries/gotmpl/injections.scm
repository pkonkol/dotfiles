;; extends

; W szablonie Helma wszystko POZA dyrektywami {{ }} jest YAML-em.
; (text) to wlasnie te fragmenty. injection.combined skleja je w jeden
; dokument przed parsowaniem — bez tego kazda linia bylaby osobnym YAML-em
; i zagniezdzenie (wciecia) by sie rozjechalo.
((text) @injection.content
 (#set! injection.language "yaml")
 (#set! injection.combined))
