const fetchImage = (imageUrl: string): Promise<HTMLImageElement> => {
  return new Promise((resolve, reject) => {
    const domImage = new Image();
    domImage.crossOrigin = 'Anonymous';
    domImage.onload = () => resolve(domImage);
    domImage.onerror = () => reject();
    domImage.src = imageUrl;
  });
};

const getBackgroundColor = (base64ImageContent: string): Promise<[number, number, number]> => {
  return fetchImage(`${base64ImageContent}`).then((domImage) => {
    const width = domImage.naturalWidth;
    const height = domImage.naturalHeight;
    const canvas = document.createElement('canvas');
    const context = canvas.getContext('2d');
    canvas.width = width;
    canvas.height = height;
    context?.drawImage(domImage, 0, 0, width, height);
    const pixels = context?.getImageData(0, 0, width, height)?.data || [];
    const pixelCount = width * height;
    const pixelArray: [number, number, number][] = [];

    for (let i = 0, offset, r, g, b, a; i < pixelCount; i += 10) {
      offset = i * 4;
      r = pixels[offset + 0];
      g = pixels[offset + 1];
      b = pixels[offset + 2];
      a = pixels[offset + 3];

      // If pixel is mostly opaque and not white
      if (a >= 125) {
        if (!(r > 254 && g > 254 && b > 254)) {
          pixelArray.push([r, g, b]);
        }
      }
    }

    const cmap = quantize(pixelArray, 5);
    const palette = cmap.palette();
    return palette[0];
  });
};

const quantize = (pixels: [number, number, number][], maxColors = 5, step = 8) => {
  const cmap = new Map();
  const res = new Map();

  const normalizeColor = ([r, g, b]: [number, number, number]): string => {
    const nr = Math.round(r / step) * step;
    const ng = Math.round(g / step) * step;
    const nb = Math.round(b / step) * step;
    return `${nr},${ng},${nb}`;
  };

  for (const [r, g, b] of pixels) {
    const key = normalizeColor([r, g, b]);
    const count = cmap.get(key) || 0;
    cmap.set(key, count + 1);
  }
  const sortedColors = Array.from(cmap.entries()).sort((a, b) => b[1] - a[1]);

  for (const [key, count] of sortedColors.slice(0, maxColors)) {
    const [r, g, b] = key.split(',').map(Number);
    res.set(key, [r, g, b, count]);
  }

  return {
    palette: () => Array.from(res.values()),
  };
};

export const findContrastColor = (rgb: [number, number, number]): [number, number, number] => {
  const [r, g, b] = rgb;
  const brightness = (r * 299 + g * 587 + b * 114) / 1000;

  // Adjust the RGB values to find a contrasting color
  const contrastR = brightness < 128 ? 250 : 25;
  const contrastG = brightness < 128 ? 250 : 25;
  const contrastB = brightness < 128 ? 250 : 25;

  return [contrastR, contrastG, contrastB];
};

export default getBackgroundColor;
