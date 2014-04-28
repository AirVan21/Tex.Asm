import os   #модуль для работы с файлами
curdir = os.getcwd() #увидим каталог, в котором мы сидим
PCI = open('PCI.txt')
while True:
  line = PCI.readline() #берем строчку из файла 
  if not line: break    #если строчки кончились, то выход из цикла
  name = ""
  for i in xrange(3, 7): #в этих символах будет vendor id
    name = name + line[i]
  if(not os.path.isdir(curdir + "/" + name)): #если не было папки с названием vendor id, то создаем такую
    os.mkdir(name)
  os.chdir(os.getcwd() + "/" + name)
  
  #дальше внутри папки с именем vendor id создаем 4 вложенных друг в друга каталога с названиями соответствующими цифре в product id. 
  #Например vendor id = 8086, product id = 1237. Тогда будет такое дерево каталогов: 8086->1->2->3->4
  #И внутри этого дерева создаем файл с названием a.txt в котором название продукта.
  #Все цифры (12, 13...18) подобраны для конкретного файла со списком PCI устройств. (Он у нас называется PCI.txt)
  name = line[12] #12 символом строки будет первая цифра product id, аналогично для остального.
  if(not os.path.isdir(os.getcwd() + "/" + name)):
    os.mkdir(name)
  os.chdir(os.getcwd() + "/" + name)
  name = line[13] 
  if(not os.path.isdir(os.getcwd() + "/" + name)):
    os.mkdir(name)
  os.chdir(os.getcwd() + "/" + name)
  name = line[14]
  if(not os.path.isdir(os.getcwd() + "/" + name)):
    os.mkdir(name)
  os.chdir(os.getcwd() + "/" + name)
  name = line[15]
  if(not os.path.isdir(os.getcwd() + "/" + name)):
    os.mkdir(name)
  os.chdir(os.getcwd() + "/" + name)
  a = open("a.txt", "w+")
  a.write(line[18:]) #записываем в файл название продукта.
  os.chdir(curdir)
PCI.close()
    

