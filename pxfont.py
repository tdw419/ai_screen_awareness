# pxos_framebuffer_writer.py
from PIL import Image
import os

# --- PXFontLib components (full PX_FONT for comprehensive writing) ---
# Define a simple 5x7 pixel font. Each character is a list of 7 strings (rows).
# 'X' represents an 'on' pixel, '.' represents an 'off' pixel.
PX_FONT = {
    ' ': [
        '.....',
        '.....',
        '.....',
        '.....',
        '.....',
        '.....',
        '.....',
    ],
    '!': [
        '..X..',
        '..X..',
        '..X..',
        '..X..',
        '.....',
        '..X..',
        '.....',
    ],
    '"': [
        'X.X..',
        'X.X..',
        'X.X..',
        '.....',
        '.....',
        '.....',
        '.....',
    ],
    '(': [
        '..X..',
        '.X...',
        '.X...',
        '.X...',
        '.X...',
        '.X...',
        '..X..',
    ],
    ')': [
        '..X..',
        '...X.',
        '...X.',
        '...X.',
        '...X.',
        '...X.',
        '..X..',
    ],
    '*': [
        'X.X.X',
        '.X.X.',
        'X.X.X',
        '.X.X.',
        'X.X.X',
        '.....',
        '.....',
    ],
    '+': [
        '.....',
        '..X..',
        '..X..',
        'XXXXX',
        '..X..',
        '..X..',
        '.....',
    ],
    ',': [
        '.....',
        '.....',
        '.....',
        '.....',
        '..X..',
        '..X..',
        '.X...',
    ],
    '-': [
        '.....',
        '.....',
        'XXXXX',
        '.....',
        '.....',
        '.....',
        '.....',
    ],
    '.': [
        '.....',
        '.....',
        '.....',
        '.....',
        '.....',
        '..X..',
        '.....',
    ],
    '/': [
        '....X',
        '...X.',
        '..X..',
        '.X...',
        'X....',
        '.....',
        '.....',
    ],
    '0': [
        '.XXX.',
        'X...X',
        'X...X',
        'X...X',
        'X...X',
        'X...X',
        '.XXX.',
    ],
    '1': [
        '..X..',
        '.XX..',
        '..X..',
        '..X..',
        '..X..',
        '..X..',
        'XXXXX',
    ],
    '2': [
        'XXXX.',
        '....X',
        'XXXX.',
        'X....',
        'X....',
        'X....',
        'XXXXX',
    ],
    '3': [
        'XXXX.',
        '....X',
        '....X',
        'XXXX.',
        '....X',
        '....X',
        'XXXX.',
    ],
    '4': [
        'X....',
        'X....',
        'X.X..',
        'X.X..',
        'XXXXX',
        '....X',
        '....X',
    ],
    '5': [
        'XXXXX',
        'X....',
        'X....',
        'XXXX.',
        '....X',
        '....X',
        'XXXX.',
    ],
    '6': [
        '.XXXX',
        'X....',
        'X....',
        'XXXX.',
        'X...X',
        'X...X',
        '.XXX.',
    ],
    '7': [
        'XXXXX',
        '....X',
        '....X',
        '...X.',
        '..X..',
        '..X..',
        '.X...',
    ],
    '8': [
        '.XXX.',
        'X...X',
        '.XXX.',
        'X...X',
        'X...X',
        'X...X',
        '.XXX.',
    ],
    '9': [
        '.XXX.',
        'X...X',
        'X...X',
        '.XXXX',
        '....X',
        '....X',
        '.XXXX',
    ],
    ':': [
        '.....',
        '..X..',
        '.....',
        '.....',
        '..X..',
        '.....',
        '.....',
    ],
    ';': [
        '.....',
        '..X..',
        '.....',
        '.....',
        '..X..',
        '..X..',
        '.X...',
    ],
    '<': [
        '....X',
        '...X.',
        '..X..',
        '.X...',
        '..X..',
        '...X.',
        '....X',
    ],
    '=': [
        '.....',
        'XXXXX',
        '.....',
        'XXXXX',
        '.....',
        '.....',
        '.....',
    ],
    '>': [
        'X....',
        '.X...',
        '..X..',
        '...X.',
        '..X..',
        '.X...',
        'X....',
    ],
    '?': [
        '.XXX.',
        'X...X',
        '....X',
        '...X.',
        '..X..',
        '.....',
        '..X..',
    ],
    '@': [
        '.XXX.',
        'X...X',
        'X.XXX',
        'X.X.X',
        'X.XXX',
        'X....',
        '.XXX.',
    ],
    'A': [
        '.XXX.',
        'X...X',
        'X.X.X',
        'XXXXX',
        'X...X',
        'X...X',
        'X...X',
    ],
    'B': [
        'XXXX.',
        'X...X',
        'X...X',
        'XXXX.',
        'X...X',
        'X...X',
        'XXXX.',
    ],
    'C': [
        '.XXXX',
        'X....',
        'X....',
        'X....',
        'X....',
        'X....',
        '.XXXX',
    ],
    'D': [
        'XXXX.',
        'X...X',
        'X...X',
        'X...X',
        'X...X',
        'X...X',
        'XXXX.',
    ],
    'E': [
        'XXXXX',
        'X....',
        'X....',
        'XXXX.',
        'X....',
        'X....',
        'XXXXX',
    ],
    'F': [
        'XXXXX',
        'X....',
        'X....',
        'XXXX.',
        'X....',
        'X....',
        'X....',
    ],
    'G': [
        '.XXXX',
        'X....',
        'X....',
        'X.XXX',
        'X...X',
        'X...X',
        '.XXX.',
    ],
    'H': [
        'X...X',
        'X...X',
        'X...X',
        'XXXXX',
        'X...X',
        'X...X',
        'X...X',
    ],
    'I': [
        'XXXXX',
        '..X..',
        '..X..',
        '..X..',
        '..X..',
        '..X..',
        'XXXXX',
    ],
    'J': [
        'XXXXX',
        '...X.',
        '...X.',
        '...X.',
        'X..X.',
        'X..X.',
        '.XX..',
    ],
    'K': [
        'X...X',
        'X..X.',
        'X.X..',
        'XX...',
        'X.X..',
        'X..X.',
        'X...X',
    ],
    'L': [
        'X....',
        'X....',
        'X....',
        'X....',
        'X....',
        'X....',
        'XXXXX',
    ],
    'M': [
        'X...X',
        'XX.XX',
        'X.X.X',
        'X.X.X',
        'X...X',
        'X...X',
        'X...X',
    ],
    'N': [
        'X...X',
        'XX..X',
        'X.X.X',
        'X.X.X',
        'X..XX',
        'X...X',
        'X...X',
    ],
    'O': [
        '.XXX.',
        'X...X',
        'X...X',
        'X...X',
        'X...X',
        'X...X',
        '.XXX.',
    ],
    'P': [
        'XXXX.',
        'X...X',
        'X...X',
        'XXXX.',
        'X....',
        'X....',
        'X....',
    ],
    'Q': [
        '.XXX.',
        'X...X',
        'X...X',
        'X...X',
        'X.X.X',
        'X..X.',
        '.XXX.X',
    ],
    'R': [
        'XXXX.',
        'X...X',
        'X...X',
        'XXXX.',
        'X..X.',
        'X...X',
        'X...X',
    ],
    'S': [
        '.XXXX',
        'X....',
        'X....',
        '.XXX.',
        '....X',
        '....X',
        'XXXX.',
    ],
    'T': [
        'XXXXX',
        '..X..',
        '..X..',
        '..X..',
        '..X..',
        '..X..',
        '..X..',
    ],
    'U': [
        'X...X',
        'X...X',
        'X...X',
        'X...X',
        'X...X',
        'X...X',
        '.XXX.',
    ],
    'V': [
        'X...X',
        'X...X',
        'X...X',
        'X...X',
        '.X.X.',
        '.X.X.',
        '..X..',
    ],
    'W': [
        'X...X',
        'X...X',
        'X.X.X',
        'X.X.X',
        'X.X.X',
        'XX.XX',
        'X...X',
    ],
    'X': [
        'X...X',
        '.X.X.',
        '..X..',
        '.X.X.',
        'X...X',
        'X...X',
        'X...X',
    ],
    'Y': [
        'X...X',
        '.X.X.',
        '..X..',
        '..X..',
        '..X..',
        '..X..',
        '..X..',
    ],
    'Z': [
        'XXXXX',
        '....X',
        '...X.',
        '..X..',
        '.X...',
        'X....',
        'XXXXX',
    ],
    '[': [
        'XXX..',
        'X....',
        'X....',
        'X....',
        'X....',
        'X....',
        'XXX..',
    ],
    '\\': [
        'X....',
        '.X...',
        '..X..',
        '...X.',
        '....X',
        '.....',
        '.....',
    ],
    ']': [
        '..XXX',
        '....X',
        '....X',
        '....X',
        '....X',
        '....X',
        '..XXX',
    ],
    '^': [
        '..X..',
        '.X.X.',
        'X...X',
        '.....',
        '.....',
        '.....',
        '.....',
    ],
    '_': [
        '.....',
        '.....',
        '.....',
        '.....',
        '.....',
        '.....',
        'XXXXX',
    ],
    '`': [
        'X....',
        '.X...',
        '.....',
        '.....',
        '.....',
        '.....',
        '.....',
    ],
    'a': [
        '.....',
        '.XXX.',
        'X...X',
        '.XXXX',
        'X...X',
        'X...X',
        '.XXX.',
    ],
    'b': [
        'X....',
        'X....',
        'X....',
        'XXXX.',
        'X...X',
        'X...X',
        'XXXX.',
    ],
    'c': [
        '.....',
        '.XXX.',
        'X....',
        'X....',
        'X....',
        'X....',
        '.XXX.',
    ],
    'd': [
        '....X',
        '....X',
        '....X',
        '.XXXX',
        'X...X',
        'X...X',
        '.XXX.',
    ],
    'e': [
        '.....',
        '.XXX.',
        'X...X',
        'XXXX.',
        'X....',
        'X....',
        '.XXX.',
    ],
    'f': [
        '..XX.',
        '.X...',
        '.X...',
        'XXX..',
        '.X...',
        '.X...',
        '.X...',
    ],
    'g': [
        '.....',
        '.XXX.',
        'X...X',
        'X...X',
        '.XXXX',
        '....X',
        '.XX..',
    ],
    'h': [
        'X....',
        'X....',
        'X....',
        'X.X..',
        'X.X.X',
        'X...X',
        'X...X',
    ],
    'i': [
        '..X..',
        '.....',
        '..X..',
        '..X..',
        '..X..',
        '..X..',
        'XXXXX',
    ],
    'j': [
        '...X.',
        '.....',
        '...X.',
        '...X.',
        'X..X.',
        'X..X.',
        '.XX..',
    ],
    'k': [
        'X....',
        'X....',
        'X.X..',
        'X.X..',
        'X..X.',
        'X...X',
        'X...X',
    ],
    'l': [
        'X....',
        'X....',
        'X....',
        'X....',
        'X....',
        'X....',
        'XXXXX',
    ],
    'm': [
        '.....',
        'X.X.X',
        'XX.XX',
        'X.X.X',
        'X...X',
        'X...X',
        'X...X',
    ],
    'n': [
        '.....',
        'X....',
        'X....',
        'X.X..',
        'X.X.X',
        'X...X',
        'X...X',
    ],
    'o': [
        '.....',
        '.XXX.',
        'X...X',
        'X...X',
        'X...X',
        'X...X',
        '.XXX.',
    ],
    'p': [
        '.....',
        'XXXX.',
        'X...X',
        'X...X',
        'XXXX.',
        'X....',
        'X....',
    ],
    'q': [
        '.....',
        '.XXXX',
        'X...X',
        'X...X',
        '.XXXX',
        '....X',
        '....X',
    ],
    'r': [
        '.....',
        'X....',
        'X....',
        'X.X..',
        'X.X.X',
        'X....',
        'X....',
    ],
    's': [
        '.....',
        '.XXXX',
        'X....',
        '.XXX.',
        '....X',
        '....X',
        'XXXX.',
    ],
    't': [
        '.X...',
        '.X...',
        'XXXXX',
        '.X...',
        '.X...',
        '.X...',
        '.XX..',
    ],
    'u': [
        '.....',
        'X...X',
        'X...X',
        'X...X',
        'X...X',
        'X...X',
        '.XXX.',
    ],
    'v': [
        '.....',
        'X...X',
        'X...X',
        'X...X',
        'X...X',
        '.X.X.',
        '..X..',
    ],
    'w': [
        '.....',
        'X...X',
        'X...X',
        'X.X.X',
        'X.X.X',
        'XX.XX',
        'X...X',
    ],
    'x': [
        '.....',
        'X...X',
        '.X.X.',
        '..X..',
        '.X.X.',
        'X...X',
        '.....',
    ],
    'y': [
        '.....',
        'X...X',
        'X...X',
        '.X.X.',
        '..X..',
        '..X..',
        '.XX..',
    ],
    'z': [
        '.....',
        'XXXXX',
        '....X',
        '...X.',
        '..X..',
        '.X...',
        'XXXXX',
    ],
    '{': [
        '..X..',
        '.X...',
        '.X...',
        'X....',
        '.X...',
        '.X...',
        '..X..',
    ],
    '|': [
        '..X..',
        '..X..',
        '..X..',
        '..X..',
        '..X..',
        '..X..',
        '..X..',
    ],
    '}': [
        '..X..',
        '...X.',
        '...X.',
        '....X',
        '...X.',
        '...X.',
        '..X..',
    ],
    '~': [
        '.....',
        'X.X.X',
        '.X.X.',
        '.....',
        '.....',
        '.....',
        '.....',
    ],
    'æ': [ # Based on Unicode char 0x00E6 (230)
        '.XXX.',
        'X...X',
        'X.X.X',
        'XXXXX', # horizontal bar
        'X...X',
        'X...X',
        '.XXX.',
    ]
}

CHAR_WIDTH = 5
CHAR_HEIGHT = 7
PIXEL_ON_COLOR = (0, 0, 0)   # Black
PIXEL_OFF_COLOR = (255, 255, 255) # White
# --- End PXFontLib components ---

def draw_char(img: Image.Image, char: str, x: int, y: int, on_color: tuple = PIXEL_ON_COLOR, off_color: tuple = PIXEL_OFF_COLOR):
    """
    Draws a single character onto the given PIL Image (framebuffer) at specified coordinates.
    """
    # Get the glyph bitmap, fallback to space if character not defined
    glyph = PX_FONT.get(char, PX_FONT.get(' ')) 
    
    for row_idx, row_str in enumerate(glyph):
        for col_idx, pixel_char in enumerate(row_str):
            px = x + col_idx
            py = y + row_idx
            
            # Determine pixel color
            color = on_color if pixel_char == 'X' else off_color
            
            # Ensure pixel is within image bounds before drawing
            if 0 <= px < img.width and 0 <= py < img.height:
                img.putpixel((px, py), color)

def write_text_to_framebuffer(img: Image.Image, text: str, start_x: int = 0, start_y: int = 0, char_spacing: int = 1, line_spacing: int = 1):
    """
    Writes a multi-line string of text onto the given PIL Image (framebuffer).
    Handles newlines and character/line spacing.
    """
    cursor_x = start_x
    cursor_y = start_y
    
    lines = text.split('\n')
    
    for line in lines:
        for char in line:
            # Check if character would go out of bounds horizontally
            if cursor_x + CHAR_WIDTH > img.width:
                # Move to next line if current line is full
                cursor_x = start_x
                cursor_y += CHAR_HEIGHT + line_spacing
                if cursor_y + CHAR_HEIGHT > img.height:
                    print("Warning: Text exceeds framebuffer height. Truncating output.")
                    return # Stop writing if out of vertical bounds

            draw_char(img, char, cursor_x, cursor_y)
            cursor_x += CHAR_WIDTH + char_spacing
        
        # After each line, move cursor to the beginning of the next line
        cursor_x = start_x
        cursor_y += CHAR_HEIGHT + line_spacing
        
        # Check if next line would go out of bounds vertically
        if cursor_y + CHAR_HEIGHT > img.height and lines.index(line) < len(lines) - 1:
            print("Warning: Text exceeds framebuffer height. Truncating output.")
            return # Stop writing if out of vertical bounds

# --- Example Usage ---
if __name__ == "__main__":
    # Define framebuffer dimensions
    # Make it large enough to comfortably fit our example text
    FB_WIDTH = 400 # pixels
    FB_HEIGHT = 100 # pixels
    OUTPUT_FILENAME = "pxsim_framebuffer_output.png"

    # 1. Create a blank simulated PNG framebuffer (PIL Image)
    framebuffer = Image.new('RGB', (FB_WIDTH, FB_HEIGHT), PIXEL_OFF_COLOR) # White background

    # Text to write
    text_to_display = (
        "Welcome to PXOS!\n"
        "This is a pixel-native environment.\n"
        "We can now write text directly to the framebuffer.\n"
        "Testing extended char: æ, and symbols: !@#$%^&*()_+-=[]{}\\|;:'\",.<>/?\n"
        "print('Hello PXOS!')"
    )

    # 2. Write the text to the framebuffer
    # Start at (10, 10) pixels from the top-left corner
    write_text_to_framebuffer(framebuffer, text_to_display, start_x=10, start_y=10, char_spacing=1, line_spacing=2)

    # 3. Save the simulated framebuffer as a PNG
    framebuffer.save(OUTPUT_FILENAME)
    print(f"\nSimulated PNG framebuffer with text saved as: {OUTPUT_FILENAME}")
    print(f"Open '{OUTPUT_FILENAME}' to see the pixel-rendered text.")

    # You can now use pxcodefont_loader.py to read this back!
    # (Ensure pxcodefont_loader.py has the full PX_FONT defined for decoding)