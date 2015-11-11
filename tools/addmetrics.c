/*
 * Copyright 2014 Nick White <nick.white@durham.ac.uk>
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Build with something like this:
 * cc `pkg-config --cflags --libs pangocairo` addmetrics.c -o addmetrics
 */

#define usage "addmetrics - calculates character metrics and adds them to a unicharset file\n" \
              "usage: addmetrics [fontnames...] < unicharset\n"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <pango/pangocairo.h>

#define LENGTH(X) (sizeof X / sizeof X[0])
#define MINZERO(x) ((x) > 0 ? (x) : 0)

#define FONTSIZE 256 /* Yields an appropriate sized character for the 256x256 square */
#define BASELINE_NORMALISE 64
#define MAXCHARBYTES 24 /* Tesseract defines this limit */
#define MAXFIELD 256
#define MAXFIELDS "256"

enum { Bottom, Top, Width, Bearing, Advance, MetricsLast }; /* Metrics */
enum { Char, Prop, Metrics, Script, Other, Dir, Mirror, Normed, UnicharLast }; /* Unicharset entries */

typedef struct {
	int min;
	int max;
} MinMax;

typedef struct {
	MinMax metrics[MetricsLast];
	char u[UnicharLast][MAXFIELD];
	int metricsunset;
} CharMetrics;

int main(int argc, char *argv[]) {
	CharMetrics *cm = NULL;
	int cmnum = 0;
	CharMetrics *cur;
	char buf[BUFSIZ];
	int metrics[MetricsLast];
	int i, j, n;
	int baseline;
	PangoFontDescription *font_description;
	PangoRectangle rect;
	cairo_surface_t *surface;
	cairo_t *cr;
	PangoLayout *layout;

	if(argc < 2) {
		fputs(usage, stdout);
		return 1;
	}

	/* Pass first 4 lines of unicharset straight through */
	for(i = 0; i < 4; i++) {
		fgets(buf, BUFSIZ, stdin);
		fputs(buf, stdout);
	}

	while(fgets(buf, BUFSIZ, stdin) != NULL) {
		cm = realloc(cm, sizeof(*cm) * ++cmnum);
		cur = cm + cmnum - 1;
		cur->metricsunset = 1;
		if(sscanf(buf, "%"MAXFIELDS"s %"MAXFIELDS"s %"MAXFIELDS"s %"MAXFIELDS"s "
		               "%"MAXFIELDS"s %"MAXFIELDS"s %"MAXFIELDS"s %"MAXFIELDS"s",
		          cur->u[Char], cur->u[Prop], cur->u[Metrics], cur->u[Script],
		          cur->u[Other], cur->u[Dir], cur->u[Mirror], cur->u[Normed])
		   != 8) {
			fprintf(stderr, "Warning, failed to read line of unicharset: %s", buf);
			cmnum--;
		}
	}

	surface = cairo_image_surface_create(CAIRO_FORMAT_ARGB32, 0, 0);
	cr = cairo_create(surface);
	layout = pango_cairo_create_layout(cr);

	for(n = 1; n < argc; n++) {
		font_description = pango_font_description_from_string(argv[n]);
		pango_font_description_set_absolute_size(font_description, FONTSIZE * PANGO_SCALE);

		pango_layout_set_font_description(layout, font_description);
		pango_font_description_free(font_description);

		baseline = (pango_layout_get_baseline(layout) / PANGO_SCALE) + BASELINE_NORMALISE;

		for(i = 0, cur = cm; i < cmnum; i++, cur++) {
			pango_layout_set_text(layout, cur->u[Char], -1);
			pango_layout_get_pixel_extents(layout, &rect, NULL);

			metrics[Bottom] = MINZERO(baseline - (rect.y + rect.height));
			metrics[Top] = MINZERO(256 - rect.y);
			metrics[Width] = rect.width;
			metrics[Bearing] = MINZERO(PANGO_LBEARING(rect));
			metrics[Advance] = MINZERO(PANGO_RBEARING(rect));

			if(cur->metricsunset) {
				for(j = 0; j < LENGTH(metrics); j++) {
					cur->metrics[j].min = cur->metrics[j].max = metrics[j];
				}
				cur->metricsunset = 0;
			}

			for(j = 0; j < LENGTH(metrics); j++) {
				if(cur->metrics[j].min > metrics[j]) {
					cur->metrics[j].min = metrics[j];
				}
				if(cur->metrics[j].max < metrics[j]) {
					cur->metrics[j].max = metrics[j];
				}
			}
		}
	}

	g_object_unref(layout);
	cairo_destroy(cr);
	cairo_surface_destroy(surface);

	for(i = 0, cur = cm; i < cmnum; i++, cur++) {
		for(j = 0; j < Metrics; j++) {
			fputs(cur->u[j], stdout);
			fputc(' ', stdout);
		}

		for(j = 0; j < LENGTH(cur->metrics); j++) {
			printf("%d,%d", cur->metrics[j].min, cur->metrics[j].max);
			if(j != LENGTH(cur->metrics) - 1) {
				fputc(',', stdout);
			}
		}

		for(j = 3; j < LENGTH(cur->u); j++) {
			fputc(' ', stdout);
			fputs(cur->u[j], stdout);
		}
		fputc('\n', stdout);
	}

	free(cm);

	return 0;
}
