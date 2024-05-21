import tkinter as tk
import threading
import serial
import pandas as pd
import numpy as np
from sklearn.linear_model import LinearRegression

# Veri setini yükleme
df = pd.read_csv("multiple_linear_regression_dataset.csv", sep=";")

# Bağımsız ve bağımlı değişkenlerin belirlenmesi
x = df.iloc[:, [0, 2, 3]].values
y = df.maas.values.reshape(-1, 1)

# Model oluşturma
multiple_linear_regression = LinearRegression()
multiple_linear_regression.fit(x, y)

print("b0: ", multiple_linear_regression.intercept_)
print("b1,b2: ", multiple_linear_regression.coef_)

# Bluetooth bağlantısı için seri portu açma
ser = serial.Serial('COM16', 9600)  # Seri portu ve baud hızını ayarlayın

def on_submit():
    try:
        # Entry bileşenlerinden verileri al
        age = int(entry1.get()) if entry1.get().isdigit() else 0
        experience = float(entry2.get()) if entry2.get().replace('.', '', 1).isdigit() else 0.0
        at = float(entry3.get()) if entry3.get().replace('.', '', 1).isdigit() else 0.0
        datax = int(ord(ser.read()))
        # Tahmin yapma
        prediction = multiple_linear_regression.predict(np.array([[datax, experience, at]]))

        # Tahmin değerinin belirlenen aralıklara göre dönüştürülmesi
        if 0 <= prediction < 1:
            speed = 1
        elif 1 <= prediction < 2:
            speed = 2
        elif 2 <= prediction < 3:
            speed = 3
        elif 3 <= prediction < 4:
            speed = 4
        elif 4 <= prediction < 5:
            speed = 5
        elif 5 <= prediction < 6:
            speed = 6
        elif 6 <= prediction < 7:
            speed = 7
        elif 7 <= prediction < 8:
            speed = 8
        else:
            speed = 1
        print(prediction)  
        # Hızı stringe dönüştürme ve Bluetooth üzerinden iletim
        speed_str = str(speed)
        ser.write(speed_str.encode())
    except Exception as e:
        print(f"Error in on_submit: {e}")

def yes():
    speed = 0
    speed_str = str(speed)
    ser.write(speed_str.encode())
    
def no():
    speed = 9
    speed_str = str(speed)
    ser.write(speed_str.encode())

class EntrY:
    def __init__(self, window, entry_width, entry_string, entry_index, entry_x, entry_y):
        self.window = window
        self.entry = tk.Entry(window, width=entry_width)
        self.entry.insert(index=entry_index, string=entry_string)
        self.entry.place(x=entry_x, y=entry_y)
    
    def set_value(self, value):
        self.entry.delete(0, tk.END)  # Mevcut değeri temizle
        self.entry.insert(0, str(value))  # Yeni değeri ekle
    
    def get(self):
        return self.entry.get()

# Photo oop
class Photo:
    def __init__(self, window, width_photo, height_photo, bg_photo, photo_cordx, photo_cordy,
                 uzanti, width_bi, height_bi, number1, number2):
        self.image = tk.PhotoImage(file=uzanti, width=width_bi, height=height_bi)
        self.canvas = tk.Canvas(window, width=width_photo, height=height_photo, bg=bg_photo, highlightthickness=0)
        self.canvas.place(relx=photo_cordx, rely=photo_cordy)
        self.canvas.create_image(number1, number2, anchor=tk.NW, image=self.image)

# Button oop
class Button:
    def __init__(self, window, text, ab, bg, fg, af, height, width, font, cordx, cordy):
        self.window = window
        self.button = tk.Button(self.window, text=text, activebackground=ab,
                                bg=bg, fg=fg, activeforeground=af,
                                font=font, height=height, width=width, command=self.buttonFunction)
        self.button.place(relx=cordx, rely=cordy)
        
        if text == "Edit":
            self.button.config(command=self.edit_function)

    def buttonFunction(self):
        if self.button == but6.button:
            on_submit()
        elif self.button == but1.button:
            yes()
        elif self.button == but2.button:
            no()

    def edit_function(self):
        # Entry bileşenlerinin ilk değerlerine dönmesi
        entry1.set_value("Temperature")
        entry2.set_value("People")
        entry3.set_value("Room")

        # Veri alımının devam etmesi için thread'i başlatma
        if not serial_thread.is_alive():
            serial_thread.start()

# Label oop
class Label:
    def __init__(self, window, text_label, font_label, fg_label, bg_label, label_wrap, label_cordx, label_cordy):
        self.window = window
        self.label = tk.Label(window, text=text_label, font=font_label, fg=fg_label, bg=bg_label,
                              wraplength=label_wrap)
        self.label.place(relx=label_cordx, rely=label_cordy)

window = tk.Tk()
window.geometry("550x800")
window.title("EmuPent")
window.configure(bg="white")
window.resizable(width=False, height=False)

# Photo
foto = Photo(window, 1000, 1000, "white", 0.05, 0.27, r"ana.png", 900, 700, 0, 0)

# Buttons
but1 = Button(window, "Yes", "white", "green", "black", "blue", 1, 6, "Courier 11", 0.22, 0.74) 
but2 = Button(window, "No", "white", "red", "black", "blue", 1, 6, "Courier 11", 0.22, 0.79)
but6 = Button(window, "Send", "white", "light blue", "black", "blue", 1, 4, "Courier 11", 0.84, 0.615)
but3 = Button(window, "Edit", "white", "gray", "black", "blue", 1, 2, "Courier 11", 0.36, 0.54) 
but4 = Button(window, "-", "white", "gray", "black", "blue", 1, 2, "Courier 11", 0.47, 0.54)

# Entries
entry1 = EntrY(window, 10, "Temperature", 0, 425, 400)
entry2 = EntrY(window, 10, "People", 0, 425, 430)
entry3 = EntrY(window, 10, "Room", 0, 425, 460)

# Labels
lab1 = Label(window, "Welcome to Your Smart Home", "Courier 22", "black", "white", 300, 0.32, 0.12)
lab2 = Label(window, "Temperature Control", "Courier 9", "black", "white", 350, 0.585, 0.46)
lab3 = Label(window, "Are You at Home?", "Courier 9", "black", "white", 350, 0.18, 0.695)
lab4 = Label(window, "Temperature", "Courier 8", "black", "red", 350, 0.71, 0.71)

def read_serial():
    while True:
        try:
            data = ser.read()
            decoded_data = data.decode('utf-8', errors='ignore')  # Decode using utf-8 and ignore errors
            if decoded_data:
                decimal_value = ord(decoded_data)  # ASCII character to decimal value
                entry1.set_value(decimal_value)  # Set the value in entry1
        except Exception as e:
            print(f"Error in read_serial: {e}")
        return decoded_data    
# Arka plan görevini başlatma
serial_thread = threading.Thread(target=read_serial)
serial_thread.daemon = True
serial_thread.start()

window.mainloop()
