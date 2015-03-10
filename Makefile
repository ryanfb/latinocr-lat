FONTSITE = http://greekfontsociety.gr
# FONTSITE = http://ancientgreekocr.org/archived # backup copies
CARDOFONTURL = http://scholarsfonts.net/cardo104.zip
FELLFONTURL = http://iginomarini.com/fell/wp-content/uploads/IMFellTypesClass.zip
EBGARAMONDFONTURL = https://bitbucket.org/georgd/eb-garamond/downloads/EBGaramond-0.016.zip
WYLDFONTURL = http://www.orbitals.com/programs/wyld.zip
WORDLISTS = \
            lat.word.txt \
            lat.freq.txt \
            lat.punc.txt
DAWGS = $(WORDLISTS:.txt=-dawg)
ifeq ($(shell uname),Darwin)
	MEDIUM = Medium
endif
FONT_NAMES = \
             "$(strip GFS Bodoni ${MEDIUM})" \
             "$(strip GFS Didot ${MEDIUM})" \
             "$(strip Cardo ${MEDIUM})" \
             "$(strip IM FELL DW Pica PRO ${MEDIUM})" \
             "$(strip IM FELL Double Pica PRO ${MEDIUM})" \
             "$(strip IM FELL English PRO ${MEDIUM})" \
             "$(strip IM FELL French Canon PRO ${MEDIUM})" \
             "$(strip IM FELL Great Primer PRO ${MEDIUM})" \
             "GFS Bodoni Bold" \
             "GFS Bodoni Bold Italic" \
             "$(strip GFS Bodoni ${MEDIUM} Italic)" \
             "GFS Didot Bold" \
             "GFS Didot Bold Italic" \
             "$(strip GFS Didot ${MEDIUM} Italic)" \
             "Cardo Bold" \
             "$(strip Cardo ${MEDIUM} Italic)" \
             "$(strip IM FELL DW Pica PRO ${MEDIUM} Italic)" \
             "$(strip IM FELL Double Pica PRO ${MEDIUM} Italic)" \
             "$(strip IM FELL English PRO ${MEDIUM} Italic)" \
             "$(strip IM FELL French Canon PRO ${MEDIUM} Italic)" \
             "$(strip IM FELL Great Primer PRO ${MEDIUM} Italic)" \
             "$(strip EB Garamond ${MEDIUM})" \
             "$(strip EB Garamond ${MEDIUM} Italic)" \
             "$(strip Wyld ${MEDIUM})" \
             "$(strip Wyld ${MEDIUM} Italic)"
LIGATURED_FONT_NAMES = \
             "$(strip Cardo ${MEDIUM})" \
             "$(strip EB Garamond ${MEDIUM})" \
             "$(strip EB Garamond ${MEDIUM} Italic)"
WYLD_FONT_NAMES = \
             "$(strip Wyld ${MEDIUM})" \
             "$(strip Wyld ${MEDIUM} Italic)"
# proprietary fonts
#             "Baskerville Medium" \
#             "Baskerville Bold" \
#             "Baskerville Bold Italic" \
#             "Baskerville Medium Italic" \
#             "Adobe Garamond Pro Medium" \
#             "Adobe Garamond Pro Bold" \
#             "Adobe Garamond Pro Bold Italic" \
#             "Adobe Garamond Pro Medium Italic" \

FONT_URLNAMES = \
                GFS_ARTEMISIA_OT \
                GFS_BODONI_OT \
                GFS_DIDOTCLASS_OT \
                GFS_DIDOT_OT \
                GFS_NEOHELLENIC_OT \
                GFS_PHILOSTRATOS \
                GFS_PORSON_OT \
                GFS_PYRSOS \
                GFS_SOLOMOS_OT
CHARSPACING = 1.0

.SUFFIXES: .txt -dawg

all: lat.traineddata

lat.traineddata:  lat.config features lat.unicharset lat.pffmtable lat.inttemp lat.shapetable lat.normproto lat.unicharambigs $(DAWGS)
	combine_tessdata lat.

fonts:
	for i in $(FONT_URLNAMES); do \
		wget -q -O $$i.zip $(FONTSITE)/$$i.zip ; \
		unzip -q -j $$i.zip ; \
		rm -f OFL-FAQ.txt OFL.txt *Specimen.pdf *Specimenn.pdf ; \
		rm -f readme.rtf .DS_Store ._* $$i.zip; \
	done
	wget -q -O cardo.zip $(CARDOFONTURL) ; \
		unzip -q -j cardo.zip ; \
		rm -f Manual104s.pdf cardo.zip
	wget -q -O fell.zip $(FELLFONTURL) ; \
		unzip -q -j fell.zip ; \
		rm -f Fell*License.txt fell.zip
	wget -q -O ebgaramond.zip $(EBGARAMONDFONTURL) ; \
		unzip -q -j ebgaramond.zip
		rm -f README.markdown COPYING README.xelualatex Specimen.pdf Changes EBGaramond*AllSC* EBGaramondSC* EBGaramond08* EBGaramond-Initials* ebgaramond.zip
	wget -q -O wyld.zip $(WYLDFONTURL) ; \
		unzip -q -j wyld.zip
		rm -f WyldMacros.dot README.TXT wyld.zip
	chmod 644 *.otf *.ttf
	touch $@

images: fonts training_text.txt
	for i in $(FONT_NAMES); do \
		n=`echo $$i | sed 's/ //g'` ; \
		for e in -3 -2 -1 0 1 2 3; do \
			text2image --exposure $$e --char_spacing $(CHARSPACING) \
			           --fonts_dir . --text training_text.txt \
			           --outputbase lat.$$n.exp$$e --font "$$i" ; \
		done ; \
	done
	touch $@

ligature_images: fonts training_text.txt
	for i in $(LIGATURED_FONT_NAMES); do \
		n=`echo $$i | sed 's/ //g'` ; \
		for e in -3 -2 -1 0 1 2 3; do \
			text2image --exposure $$e --char_spacing $(CHARSPACING) \
			           --fonts_dir . --text training_text.txt \
			           --ligatures --outputbase lat.liga.$$n.exp$$e --font "$$i" ; \
		done ; \
	done
	./wyld.sed training_text.txt > wyld_training_text.txt
	for i in $(WYLD_FONT_NAMES); do \
		n=`echo $$i | sed 's/ //g'` ; \
		for e in -3 -2 -1 0 1 2 3; do \
			text2image --exposure $$e --char_spacing $(CHARSPACING) \
			           --fonts_dir . --text wyld_training_text.txt \
			           --ligatures --outputbase lat.liga.$$n.exp$$e --font "$$i" ; \
			./wyld-reverse.sed lat.liga.$$n.exp$$e.box > lat.liga.$$n.exp$$e.box.fixed ; \
			mv -v lat.liga.$$n.exp$$e.box.fixed lat.liga.$$n.exp$$e.box ; \
		done ; \
	done
	touch $@

# .tr files
features: images ligature_images
	for i in *tif; do b=`basename $$i .tif`; tesseract $$i $$b box.train; done
	touch $@

# unicharset to pass to mftraining
lat.earlyunicharset: images ligature_images
	unicharset_extractor *box
	set_unicharset_properties -U unicharset -O $@ --script_dir .
	rm unicharset

# cntraining
lat.normproto: features
	cntraining lat*tr
	mv normproto $@

# mftraining
%.unicharset %.inttemp %.pffmtable %.shapetable: %.earlyunicharset features font_properties
	mftraining -F font_properties -U lat.earlyunicharset -O lat.unicharset lat*tr
	for i in inttemp pffmtable shapetable; do mv $$i $*.$$i; done

.txt-dawg: lat.unicharset # for the newest .unicharset
	wordlist2dawg $< $@ lat.unicharset

install: lat.traineddata
	cp lat.traineddata ../../../tessdata

clean:
	rm -f images features mftraining *tif *box *tr *dawg lat.GFS*txt ligature_images
	rm -f lat.inttemp lat.normproto lat.pffmtable lat.shapetable lat.unicharset lat.earlyunicharset

cleanfonts:
	rm -f fonts *otf
