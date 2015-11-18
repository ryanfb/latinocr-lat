FONTSITE = http://greekfontsociety.gr
# FONTSITE = http://ancientgreekocr.org/archived # backup copies
CARDOFONTURL = http://scholarsfonts.net/cardo104.zip
FELLFONTURL = http://iginomarini.com/fell/wp-content/uploads/IMFellTypesClass.zip
EBGARAMONDFONTURL = https://bitbucket.org/georgd/eb-garamond/downloads/EBGaramond-0.016.zip
WYLDFONTURL = http://www.orbitals.com/programs/wyld.zip
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

FONT_LIST_TESS = \
								 'GFS Bodoni \
								 + GFS Bodoni Bold \
								 + GFS Bodoni Italic \
								 + GFS Bodoni Bold Italic \
								 + GFS Didot \
								 + GFS Didot Bold \
								 + GFS Didot Italic \
								 + GFS Didot Bold Italic \
								 + Cardo \
								 + Cardo Bold \
								 + Cardo Italic \
								 + Wyld \
								 + Wyld Italic \
								 + EB Garamond \
								 + EB Garamond Italic \
								 + IM FELL DW Pica PRO \
								 + IM FELL English PRO \
								 + IM FELL Double Pica PRO \
								 + IM FELL French Canon PRO \
								 + IM FELL Great Primer PRO \
								 + IM FELL DW Pica PRO Italic \
								 + IM FELL English PRO Italic \
								 + IM FELL Double Pica PRO Italic \
								 + IM FELL French Canon PRO Italic \
								 + IM FELL Great Primer PRO Italic'

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
CAIROCFLAGS = `pkg-config --cflags pangocairo`
CAIROLDFLAGS = `pkg-config --libs pangocairo`

UTFSRC = tools/libutf/rune.c tools/libutf/utf.c

.SUFFIXES: .txt -dawg

all: lat.traineddata

GENLANGDATA = \
	langdata/lat/lat.config \
	langdata/lat/lat.training_text \
	langdata/lat/lat.training_text.unigram_freqs \
	langdata/lat/lat.unicharambigs \
	langdata/lat/lat.punc \
	langdata/lat/lat.numbers \
	langdata/lat/lat.wordlist \
	langdata/lat/lat.unicharset \
	langdata/lat/lat.xheights \
	langdata/Latin.unicharset \
	langdata/Latin.xheights \
	langdata/font_properties

langdata/lat/lat.training_text langdata/lat/lat.training_text.unigram_freqs langdata/lat/lat.wordlist: latinocr-lattraining
	mkdir -p langdata/lat
	$(MAKE) -C latinocr-lattraining
	cp -v latinocr-lattraining/lat.training_text latinocr-lattraining/lat.training_text.unigram_freqs latinocr-lattraining/lat.wordlist langdata/lat

AMBIGS = \
				 unicharambigs/common.unicharambigs \
				 unicharambigs/ligatures.unicharambigs \
				 unicharambigs/long-s.unicharambigs \
				 unicharambigs/orthographic.unicharambigs \
				 unicharambigs/ct.unicharambigs

lat.traineddata: $(GENLANGDATA) fonts/download
	tesstrain.sh --exposures -3 -2 -1 0 1 2 3 --fonts_dir fonts --fontlist $(FONT_LIST_TESS) --lang lat --langdata_dir langdata --overwrite --output_dir .

langdata/lat/lat.config: lat.config
	mkdir -p langdata/lat
	cp -v $< $@

langdata/lat/lat.punc: lat.punc.txt
	mkdir -p langdata/lat
	cp -v $< $@

langdata/lat/lat.numbers: lat.numbers.txt
	mkdir -p langdata/lat
	cp -v $< $@

fonts/download:
	rm -rf fonts
	mkdir -p fonts
	cd fonts && for i in $(FONT_URLNAMES); do \
		wget -q -O $$i.zip $(FONTSITE)/$$i.zip ; \
		unzip -q -j $$i.zip ; \
		rm -f OFL-FAQ.txt OFL.txt *Specimen.pdf *Specimenn.pdf ; \
		rm -f readme.rtf .DS_Store ._* $$i.zip; \
	done
	cd fonts && wget -q -O cardo.zip $(CARDOFONTURL) ; \
		unzip -q -j cardo.zip ; \
		rm -f Manual104s.pdf cardo.zip
	cd fonts && wget -q -O fell.zip $(FELLFONTURL) ; \
		unzip -q -j fell.zip ; \
		rm -f Fell*License.txt fell.zip
	cd fonts && wget -q -O ebgaramond.zip $(EBGARAMONDFONTURL) ; \
		unzip -q -j ebgaramond.zip ; \
		rm -f README.markdown COPYING README.xelualatex Specimen.pdf Changes EBGaramond*AllSC* EBGaramondSC* EBGaramond08* EBGaramond-Initials* ebgaramond.zip
	cd fonts && wget -q -O wyld.zip $(WYLDFONTURL) ; \
		unzip -q -j wyld.zip ; \
		rm -f WyldMacros.dot README.TXT wyld.zip
	cd fonts && chmod 644 *.otf *.ttf
	touch $@

ligature_images: fonts training_text.txt
	for i in $(LIGATURED_FONT_NAMES); do \
		n=`echo $$i | sed 's/ //g'` ; \
		for e in -3 -2 -1 0 1 2 3; do \
			text2image --exposure $$e --char_spacing $(CHARSPACING) \
			           --fonts_dir . --text training_text.txt \
			           --ligatures --outputbase lat.liga.$$n.exp$$e --font "$$i" ; \
			./tools/ligatured-reverse.sed lat.liga.$$n.exp$$e.box > lat.liga.$$n.exp$$e.box.fixed ; \
			mv -v lat.liga.$$n.exp$$e.box.fixed lat.liga.$$n.exp$$e.box ; \
		done ; \
	done
	./tools/wyld.sed training_text.txt > wyld_training_text.txt
	for i in $(WYLD_FONT_NAMES); do \
		n=`echo $$i | sed 's/ //g'` ; \
		for e in -3 -2 -1 0 1 2 3; do \
			text2image --exposure $$e --char_spacing $(CHARSPACING) \
			           --fonts_dir . --text wyld_training_text.txt \
			           --ligatures --outputbase lat.liga.$$n.exp$$e --font "$$i" ; \
			./tools/wyld-reverse.sed lat.liga.$$n.exp$$e.box > lat.liga.$$n.exp$$e.box.fixed ; \
			mv -v lat.liga.$$n.exp$$e.box.fixed lat.liga.$$n.exp$$e.box ; \
		done ; \
	done
	touch $@

tools/xheight: tools/xheight.c
	$(CC) $(CAIROCFLAGS) $(UTFSRC) $@.c -o $@ $(CAIROLDFLAGS)

tools/addmetrics: tools/addmetrics.c
	$(CC) $(CAIROCFLAGS) $(UTFSRC) $@.c -o $@ $(CAIROLDFLAGS)

langdata/Latin.xheights: tools/xheight
	mkdir -p langdata
	rm -f $@
	for i in $(FONT_NAMES); do \
		./tools/xheight "$$i" \
		| awk '{for(i=1;i<NF-1;i++) {printf("%s_",$$i)} printf("%s %d\n", $$(NF-1), $$NF)}' \
		>>$@ ; \
	done

langdata/lat/lat.xheights: langdata/Latin.xheights
	mkdir -p langdata/lat
	cp -v $< $@

langdata/font_properties: font_properties
	mkdir -p langdata
	cp -v $< $@

langdata/Latin.unicharset : tools/addmetrics latinocr-lattraining/allchars.txt
	mkdir -p langdata
	rm -f $@ allchars.box unicharset
	sed 's/$$/ 0 0 0 0 0/g' < latinocr-lattraining/allchars.txt > allchars.box
	unicharset_extractor allchars.box
	set_unicharset_properties -U unicharset -O unicharset --script_dir .
	./tools/addmetrics $(FONT_NAMES) < unicharset > $@

langdata/lat/lat.unicharset: langdata/Latin.unicharset
	mkdir -p langdata/lat
	cp -v $< $@

langdata/lat/lat.unicharambigs: $(AMBIGS)
	mkdir -p langdata/lat
	echo v1 > $@
	cat $(AMBIGS) >> $@

install: lat.traineddata
	cp lat.traineddata ../../../tessdata

clean:
	rm -f tools/xheights tools/addmetrics
	rm -f images features mftraining *tif *box *tr *dawg lat.GFS*txt ligature_images
	rm -f lat.inttemp lat.normproto lat.pffmtable lat.shapetable lat.unicharset lat.earlyunicharset
	rm -rf fonts
	rm -f $(GENLANGDATA)
	$(MAKE) -C latinocr-lattraining clean
	rm -f lat.traineddata

cleanfonts:
	rm -f fonts *otf
