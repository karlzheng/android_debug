#include <unistd.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <fcntl.h>
#include <linux/fb.h>
#include <sys/mman.h>

inline static unsigned short rgb_2_16bpp(unsigned char r, unsigned char g, unsigned char b)
{
    return ( (((r >> 3) & 31) << 11) | (((g >> 2) & 63) << 5) | ((b >> 3) & 31) );
}

int main(int argc, char **argv)
{
	struct fb_var_screeninfo vinfo;
	struct fb_fix_screeninfo finfo;
	long int screen_size = 0;
	long int location    = 0;
	int  y_draw_height   = 20; 
	int  x_draw_begin    = 10;
	int  time_cnt = 0;
	char *fbp     = 0;
	int  fbfd     = 0;
	int  x        = 0;
	int  y        = 0;
	char fb_path [512] = {0,};

	if (argc == 2 && strlen(argv[1]) < 512)
		strcpy(fb_path, argv[1]);
	else
		strcpy(fb_path, "/dev/graphics/fb0");

	fbfd = open(fb_path, O_RDWR);
	if (!fbfd) {
		printf("Error: cannot open framebuffer device.\n");
		exit(1);
	}
	printf("The framebuffer device was opened successfully.\n");

	if (ioctl(fbfd, FBIOGET_FSCREENINFO, &finfo)) {
		printf("Error reading fixed information.\n");
		exit(2);
	}

	if (ioctl(fbfd, FBIOGET_VSCREENINFO, &vinfo)) {
		printf("Error reading variable information.\n");
		exit(3);
	}

	printf("Screen vinfo:%dx%d, %dbpp\n", vinfo.xres, vinfo.yres, vinfo.bits_per_pixel );
	printf("xoffset:%d, yoffset:%d, line_length: %d\n", vinfo.xoffset, vinfo.yoffset, finfo.line_length );

	screen_size = vinfo.xres * vinfo.yres * vinfo.bits_per_pixel / 8;;

	// Map the device to memory
	fbp = (char *)mmap(0, screen_size, PROT_READ | PROT_WRITE, MAP_SHARED, fbfd, 0);

	if ((int)fbp == -1) {
		printf("Error: failed to map framebuffer device to memory.\n");
		exit(4);
	}
	printf("The framebuffer device was mapped to memory successfully.\n");

	//set to black color first
	memset(fbp, 0, screen_size);

	for ( x = x_draw_begin; x < vinfo.xres - x_draw_begin; x++ ) {
		for ( y = (vinfo.yres - y_draw_height) / 2; y < (vinfo.yres + y_draw_height) / 2; y++ ) {
			location = x * (vinfo.bits_per_pixel/8) + y * finfo.line_length;

			if ( vinfo.bits_per_pixel == 32 ) {
				*(fbp + location) = 100;      
				*(fbp + location + 1) = x%255; 
				*(fbp + location + 2) = y%255;  
				*(fbp + location + 3) = 0;        // No transparency
			} else {                              //assume 16bpp
				unsigned char b = 255 * x / (vinfo.xres - x_draw_begin);
				unsigned char g = 255;            // (x - 100)/6 A little green
				unsigned char r = 255;            // A lot of red
				unsigned short int t = rgb_2_16bpp(r, g, b);
				*((unsigned short int*)(fbp + location)) = t;
			}
		}
		usleep(200);
	}

	while (time_cnt++ < 10000) {
		usleep(200);
	}

	munmap(fbp, screen_size);
	close(fbfd);

	return 0;
}

