from naoqi import ALProxy
import time
import sys
import argparse
import cv2
from skimage import filters, feature, io, transform
from skimage.color import rgb2gray
from PIL import Image
import numpy as np
import vision_definitions
"""
  First get an image from Nao, then show it on the screen with PIL.
  """
def get_image_as_array(ip, port):
    foreheadCam = 2
    camProxy = ALProxy("ALVideoDevice", ip, port)
    # visionProxy = ALProxy("ALVisionRecognition", ip, port)
    # visionProxy.open
    camProxy.setParam(vision_definitions.kCameraSelectID, foreheadCam)
    resolution = 3    # VGA
    colorSpace = 11   # RGB

    videoClient = camProxy.subscribe("python_client", resolution, colorSpace, 5)
  # Get a camera image.
  # image[6] contains the image data passed as an array of ASCII chars.
    naoImage = camProxy.getImageRemote(videoClient)

    camProxy.unsubscribe(videoClient)


  # Now we work with the image returned and save it as a PNG  using ImageDraw
  # package.

  # Get the image size and pixel array.
    imageWidth = naoImage[0]
    imageHeight = naoImage[1]
    array = naoImage[6]
    im = Image.frombytes("RGB", (imageWidth, imageHeight), array)
    np_im = np.asarray(im)
    return rgb2gray(np_im)

if __name__ == "__main__":
  # image = get_image_as_array("10.30.4.32", 9559)  
  image = cv2.imread('naolympics\\vision\\emptyTicTacToe.png')
  image = image[int(image.shape[0]*0.1):int(image.shape[0]*0.9), int(image.shape[1]*0.3):int(image.shape[1]*0.7)]

  # Bild in Graustufen umwandeln
  gray = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)

  # Kantenerkennung anwenden
  edges = cv2.Canny(gray, 50, 150)

  # Schwellenwert anwenden, um Binaerbild zu erstellen
  ret, threshold = cv2.threshold(edges, 127, 255, cv2.THRESH_BINARY)

  # Linien mit der Hough-Transformation erkennen
  lines = cv2.HoughLinesP(threshold, 1, 3.1415 / 180, 100, minLineLength=100, maxLineGap=10)

  # Schwellenwert fuer den Abstand der Linien festlegen
  distance_threshold = 10
  merged_lines = []

  # Zusammenfuehren naher Linien
  if lines is not None:
      
    for line in lines:
      x1, y1, x2, y2 = line[0]
      merged = False
          
      for merged_line in merged_lines:
        mx1, my1, mx2, my2 = merged_line
              
    # Berechne den Abstand zwischen den Linien
        distance = np.math.sqrt((x1 - mx1) ** 2 + (y1 - my1) ** 2)
              
    # Wenn der Abstand kleiner als der Schwellenwert ist, fuege die Linien zusammen
              
        if distance < distance_threshold:
            merged_line[0] = min(x1, mx1)
            merged_line[1] = min(y1, my1)
            merged_line[2] = max(x2, mx2)
            merged_line[3] = max(y2, my2)
            merged = True
            break
          
          # Wenn die Linie nicht mit anderen Linien zusammengefuehrt wurde, fuege sie als neue Linie hinzu
      if not merged:
        merged_lines.append([x1, y1, x2, y2])

      # Gefundene Linien im Originalbild zeichnen
    for line in merged_lines:
      x1, y1, x2, y2 = line
      cv2.line(image, (x1, y1), (x2, y2), (0, 255, 0), 3)  # Gruene Linie zeichnen

  estimated_corners = []

  for line in merged_lines:
      x1, y1, x2, y2 = line
      estimated_corners.extend([(x1, y1), (x2, y2)])

  # Bestimme die Ausrichtung der Linien (horizontal oder vertikal)
  horizontal_lines = []
  vertical_lines = []

  for i in range(len(estimated_corners)):
      for j in range(i + 1, len(estimated_corners)):
          x1, y1 = estimated_corners[i]
          x2, y2 = estimated_corners[j]

          if abs(y2 - y1) < abs(x2 - x1):
              horizontal_lines.append((x1, y1, x2, y2))
          else:
              vertical_lines.append((x1, y1, x2, y2))

  # Gruppierung der horizontalen Linien, um Zeilen zu bestimmen
  horizontal_lines = sorted(horizontal_lines, key=lambda line: line[0])
  row_lines = []

  for line in horizontal_lines:
      if len(row_lines) == 0 or abs(line[1] - row_lines[-1][1]) > 10:
          row_lines.append(line)
      else:
          row_lines[-1] = (min(row_lines[-1][0], line[0]), row_lines[-1][1], max(row_lines[-1][2], line[2]), row_lines[-1][3])

  # Gruppierung der vertikalen Linien, um Spalten zu bestimmen
  vertical_lines = sorted(vertical_lines, key=lambda line: line[1])
  column_lines = []

  for line in vertical_lines:
      if len(column_lines) == 0 or abs(line[0] - column_lines[-1][0]) > 10:
          column_lines.append(line)
      else:
          column_lines[-1] = (column_lines[-1][0], min(column_lines[-1][1], line[1]), column_lines[-1][2], max(column_lines[-1][3], line[3]))

  # Kombination von Zeilen und Spalten, um Eckpunkte der Zellen zu erhalten
  cells = []

  for row_line in row_lines:
      for column_line in column_lines:
          x1, y1, x2, y2 = column_line
          cells.append((x1, row_line[1], x2, row_line[3]))

  filtered_cells = []
  
  for line in merged_lines:
    for cell in cells:
      if()
      

  for cell in cells:
      x, y, width, height = cell

      # Eckpunkte der Zelle
      top_left = (x, y)
      top_right = (x + width, y)
      bottom_right = (x + width, y + height)
      bottom_left = (x, y + height)

      # Zeichne die Eckpunkte als Kreuze
      cv2.drawMarker(image, top_left, (0, 0, 255), cv2.MARKER_CROSS, 10, 2)
      cv2.drawMarker(image, top_right, (0, 0, 255), cv2.MARKER_CROSS, 10, 2)
      cv2.drawMarker(image, bottom_right, (0, 0, 255), cv2.MARKER_CROSS, 10, 2)
      cv2.drawMarker(image, bottom_left, (0, 0, 255), cv2.MARKER_CROSS, 10, 2)

  # ...

  # Bild anzeigen
  cv2.imshow('Spielbrett mit Eckpunkten', image)
  cv2.waitKey(0)
  cv2.destroyAllWindows()

    # print(field_positions)
    # io.imsave("test.png", result)
