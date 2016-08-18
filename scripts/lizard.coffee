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
  "http://www.thesundaytimes.co.uk/sto/multimedia/dynamic/00349/STG16ICKE1_349596k.jpg",
  "http://www.neonnettle.com/feed/images/david-icke_1117962c.jpg",
  "https://anti-nwo.dk/wilderdk/bin/images/david_icke_secrets_of_the_matrix_2003_0.jpg",
  "http://www.complottisti.com/wp-content/uploads/2015/12/POLICE_STATE_NWO_2014_David_Icke__161412.jpg",
  "http://justenergyradio.com/wp-content/uploads/2016/03/David-Icke.jpg",
  "http://api.ning.com/files/Rcd9iMr-jpbaB26iFBsdfG2RyB77-agKiuVpxE62Z7KCTmBt6PWkkkfoQ6o6Ljoq-vVyU2kPE**oZ*sIycJ-GQz7iKuqgcok/icke.jpeg",
  "http://whale.to/c/bransonicke87c.jpg",
  "https://www.infiniteloveforum.com/download/file.php?id=466",
  "https://missiongalacticfreedom.files.wordpress.com/2014/06/david-icke-bbff.jpg?w=540&h=245",
  "https://thrivedebunked.files.wordpress.com/2012/02/icke-header.jpg",
  "https://i.ytimg.com/vi/vL1qMW81VUA/maxresdefault.jpg"]

  robot.hear /(?!^hubot)(lizard|icke|ilumin.*)/, (msg) ->
   msg.send msg.random quality_david_icke_pics

  robot.respond /lizard (me )?(.*)/i, (msg) ->
   n = parseInt(msg.match[2], 10) || 1;
   for i in [1..n]
     msg.send msg.random quality_david_icke_pics
