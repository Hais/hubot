module.exports = (robot) ->

  quality_david_icke_pics = ["http://3.darkroom.shortlist.com/980/4ea900a33a80bbe0f78866628d8d296d:8302d8ba977ee334ce0dac226ce0bf7b/david-icke.jpg"
  "http://chronicle.su/wp-content/uploads/reptilian1.jpg ",
  "http://i.ytimg.com/vi/_EQyeZCZyUM/maxresdefault.jpg",
  "https://pbs.twimg.com/profile_images/2330201343/image.jpg",
  "http://www.jesus-is-savior.com/Wolves/david_icke_illuminati_plant.jpg",
  "http://ageoftruth.dk/wp-content/uploads/2012/07/david_icke_its_a_tough_game_son_piccolo_1983_front.jpg",
  "http://www.zengardner.com/wp-content/uploads/David-Icke-Quote-23-640x470.jpg",
  "http://www.stuartwilde.com/img_2011/david_icke.jpg",
  "http://2.bp.blogspot.com/-hFwIOSZyrU0/Tpy3-gILPcI/AAAAAAAABV8/uZzsTTumKgw/s1600/cameron_is_a_lizard_desktop.jpg",
  "http://www.thesundaytimes.co.uk/sto/multimedia/dynamic/00349/STG16ICKE1_349596k.jpg"]

  robot.hear /(lizard|icke|ilumin.*)/, (msg) ->
   msg.send msg.random quality_david_icke_pics
