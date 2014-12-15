FONTSITE = http://greekfontsociety.gr
# FONTSITE = http://ancientgreekocr.org/archived # backup copies
WORDLISTS = \
            lat.word.txt \
            lat.freq.txt \
            lat.punc.txt \
            lat.number.txt
DAWGS = $(WORDLISTS:.txt=-dawg)
FONT_NAMES = \
             "GFS Artemisia Medium" \
             "GFS Artemisia Bold" \
             "GFS Artemisia Bold Italic" \
             "GFS Artemisia Medium Italic" \
             "GFS Bodoni Medium" \
             "GFS Bodoni Bold" \
             "GFS Bodoni Bold Italic" \
             "GFS Bodoni Medium Italic" \
             "GFS Didot Medium" \
             "GFS Didot Bold" \
             "GFS Didot Bold Italic" \
             "GFS Didot Medium Italic" \
             "GFS DidotClassic Medium" \
             "GFS Neohellenic Medium" \
             "GFS Neohellenic Bold" \
             "GFS Neohellenic Bold Italic" \
             "GFS Neohellenic Medium Italic" \
             "GFS Philostratos Medium" \
             "GFS Porson Medium" \
             "GFS Pyrsos Medium" \
             "GFS Solomos Medium"
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

lat.traineddata: features mftraining lat.normproto lat.unicharambigs $(DAWGS)
	combine_tessdata lat.

fonts:
	for i in $(FONT_URLNAMES); do \
		wget -q -O $$i.zip $(FONTSITE)/$$i.zip ; \
		unzip -q -j $$i.zip ; \
		rm -f OFL-FAQ.txt OFL.txt *Specimen.pdf *Specimenn.pdf ; \
		rm -f readme.rtf .DS_Store ._* $$i.zip; \
	done
	chmod 644 *otf
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

# .tr files
features: images
	for i in *tif; do b=`basename $$i .tif`; tesseract $$i $$b box.train; done
	touch $@

# unicharset to pass to mftraining
lat.earlyunicharset: images
	unicharset_extractor *box
	set_unicharset_properties -U unicharset -O $@ --script_dir .
	rm unicharset

# cntraining
lat.normproto: features
	cntraining lat*tr
	mv normproto $@

# mftraining
mftraining: lat.earlyunicharset features font_properties
	mftraining -F font_properties -U lat.earlyunicharset -O lat.unicharset lat*tr
	for i in inttemp pffmtable shapetable; do mv $$i lat.$$i; done
	touch mftraining

.txt-dawg: mftraining # for the newest .unicharset
	wordlist2dawg $< $@ lat.unicharset

install: lat.traineddata
	cp lat.traineddata ../../../tessdata

clean:
	rm -f images features mftraining *tif *box *tr *dawg lat.GFS*txt
	rm -f lat.inttemp lat.normproto lat.pffmtable lat.shapetable lat.unicharset lat.earlyunicharset

cleanfonts:
	rm -f fonts *otf
