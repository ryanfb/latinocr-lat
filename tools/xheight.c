/*
 * Copyright 2014 Nick White <nick.white@durham.ac.uk>
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Build with something like this:
 * cc `pkg-config --cflags --libs pangocairo` xheight.c -o xheight
 */

#define usage "xheight - roughly calculates the xheight for a font\n" \
              "usage: xheight fontname\n"

#include <stdio.h>
#include <pango/pangocairo.h>

#define FONTSIZE 128

int main(int argc, char *argv[]) {
	PangoFontDescription *font_description;
	PangoRectangle rect;
	cairo_surface_t *surface;
	cairo_t *cr;
	PangoLayout *layout;

	if(argc != 2) {
		fputs(usage, stdout);
		return 1;
	}

	surface = cairo_image_surface_create(CAIRO_FORMAT_ARGB32, 0, 0);
	cr = cairo_create(surface);
	layout = pango_cairo_create_layout(cr);

	font_description = pango_font_description_from_string(argv[1]);
	pango_font_description_set_absolute_size(font_description, FONTSIZE * PANGO_SCALE);

	pango_layout_set_font_description(layout, font_description);
	pango_font_description_free(font_description);

	pango_layout_set_text(layout, "x", -1);
	pango_layout_get_pixel_extents(layout, &rect, NULL);

	printf("%s %d\n", argv[1], rect.height);

	g_object_unref(layout);
	cairo_destroy(cr);
	cairo_surface_destroy(surface);

	return 0;
}
