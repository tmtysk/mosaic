int mosaic_pixel_size_small = 7;
int display_width = 1680;
int display_height = 1050;
int resized_width = 4000;
float threshold = 10.0;
float step = 0.2;
String photo_dir = "/path/to/pieces/";
String target_photo_dir = "/path/to/target/photos/";
String new_target_photo_dir = "/path/to/output/";
String resized_photo_dir = "/path/to/resized/";
String[] targets, new_targets;
int[] filters = {BURN, MULTIPLY, DARKEST};
PImage photo, mosaic;
PImage[] photo_palette;
color[] palette_colors;

// wrj4P5
//import lll.wrj4P5.*;
//import lll.Loc.*;
//Wrj4P5 wii;float pos=1;int lastFr=0;

void setup()
{
  // generating palette
  File photos = new File(photo_dir);
  File target_photos = new File(target_photo_dir);
  String[] filenames = photos.list();
  targets = target_photos.list();
  photo_palette = new PImage[filenames.length];
  palette_colors = new color[filenames.length];
  for(int i=0; i < filenames.length; i++) {
    if (filenames[i].charAt(0) == '.') continue;
    photo_palette[i] = loadImage(photo_dir + filenames[i]);
    photo_palette[i].resize(mosaic_pixel_size_small, mosaic_pixel_size_small);
    palette_colors[i] = blendColor(photo_palette[i].get(mosaic_pixel_size_small/2, mosaic_pixel_size_small/2),
      blendColor(photo_palette[i].get(0,0),
      photo_palette[i].get(mosaic_pixel_size_small, mosaic_pixel_size_small), BLEND), BLEND);
  }
  
  // loading target photo
  photo = loadImage(target_photo_dir + targets[1]);
  mosaic = makeMosaicPhoto(photo, mosaic_pixel_size_small);
  
  // rendaring
  size(display_width, display_height);
  background(0);
  image(mosaic, (display_width/2)-(photo.width/2), (display_height/2)-(photo.height/2));
  frameRate(1);
}

void draw()
{
  if((second()%5) == 0)
  {
    boolean changed = false;
    File new_target_photos = new File(new_target_photo_dir);
    new_targets = new_target_photos.list();
    if(new_targets.length > 0)
    {
      for(int i=0; i < new_targets.length; i++) {
        if (new_targets[i].charAt(0) == '.') continue;
        String new_target = new_targets[i];
        photo = loadImage(new_target_photo_dir + new_target);
        mosaic = makeMosaicPhoto(photo, mosaic_pixel_size_small);
        changed = true;
      }
    }
    if(!changed)
    {
      String target = targets[(int)random(targets.length)];
      if (target.charAt(0) != '.')
      {
        photo = loadImage(target_photo_dir + target);
        mosaic = makeMosaicPhoto(photo, mosaic_pixel_size_small);
        changed = true;
      }
    }
    background(0);
    image(mosaic, (display_width/2)-(photo.width/2), (display_height/2)-(photo.height/2));
  }
}

void keyPressed()
{
  println("key pressed");
  if(keyCode == ENTER) {
    //mosaic.save("/path/to/awc-"+(new Integer(millis())).toString()+".jpg");
    //saveFrame();
    PImage resized = createImage(photo.width, photo.height, ARGB);
    resized = photo.get();
    resized.resize(resized_width, 0);
    //resized = makeMosaicPhoto(resized, mosaic_pixel_size_small);
    resized.save(resized_photo_dir + "resized.jpg");
  }
}

void buttonPressed(RimokonEvent ev, int rid)
{
  if(ev.wasPressed(RimokonEvent.A)) {
    PImage resized = createImage(photo.width, photo.height, ARGB);
    resized = photo.get();
    resized.resize(resized_width, 0);
    resized.save(resized_photo_dir + "resized.jpg");
  }
}

PImage makeMosaicPhoto(PImage img, int mosaic_pixel_size)
{
  PImage mimg = createImage(img.width, img.height, ARGB), pp;
  PImage color_piece = createImage(mosaic_pixel_size, mosaic_pixel_size, ARGB);
  color c;
  int a;
  float th = threshold;
  for(int x = 0; x < img.width; x += mosaic_pixel_size) {
    for(int y = 0; y < img.height; y += mosaic_pixel_size) {
      
      // sampling color of 1 piece
      c = img.get(x, y);
      for(int xx = 0; xx < mosaic_pixel_size; xx++) {
        for(int yy = 0; yy < mosaic_pixel_size; yy++) {
          c = blendColor(c, img.get(x + xx, y + yy), BLEND);
        }
      }
      
      // creating image of sampled color
      for (int i = 0; i < color_piece.pixels.length; i++) {
        color_piece.pixels[i] = c;
      }
      color_piece.updatePixels();

      // picking up photo to use to piece
      int r = (int)random(palette_colors.length);
      pp = color_piece.get();
      pp.blend(photo_palette[r], 0, 0, mosaic_pixel_size, mosaic_pixel_size, 0, 0, mosaic_pixel_size, mosaic_pixel_size, OVERLAY);
      mimg.copy(pp,0,0,mosaic_pixel_size,mosaic_pixel_size,x,y,mosaic_pixel_size,mosaic_pixel_size);
      th = threshold;
    }
  }

  return mimg;
}

float clch(color a, color b)
{
  int rr, gg, bb;
  float cl;
  rr = (int)(red(a) - red(b));
  gg = (int)(green(a) - green(b));
  bb = (int)(blue(a) - blue(b));
  cl = sqrt(rr * rr + gg * gg + bb * bb);
  return cl;
}
