const texts = {
  de: {
    tagline: "Willkommen bei Ki Musik Promotion – wo KI und Emotion verschmelzen.",
    about: "Über mich",
    aboutText:
      "Ich erstelle KI-generierte Musik inspiriert von Klassik, Gospel und Jazz. Tauche ein in emotionale Klänge, die Technologie und Seele verbinden.",
    listen: "Jetzt anhören",
    contactTitle: "Kontakt",
    contactText: "Für Anfragen oder Kooperationen schreibe an:"
  },
  en: {
    tagline: "Welcome to Ki Musik Promotion – where AI meets emotion.",
    about: "About Me",
    aboutText:
      "I create AI-generated music inspired by classical, gospel, and jazz. Dive into emotional sounds that merge technology and soul.",
    listen: "Listen Now",
    contactTitle: "Contact",
    contactText: "For inquiries or collaborations, write to:"
  },
  pt: {
    tagline: "Bem-vindo à Ki Musik Promotion – onde a IA encontra a emoção.",
    about: "Sobre mim",
    aboutText:
      "Crio música gerada por IA inspirada em música clássica, gospel e jazz. Mergulhe em sons emocionais que unem tecnologia e alma.",
    listen: "Ouça agora",
    contactTitle: "Contato",
    contactText: "Para consultas ou colaborações, escreva para:"
  }
};

function changeLanguage(lang) {
  const t = texts[lang];
  document.getElementById("tagline").innerText = t.tagline;
  document.getElementById("about").innerText = t.about;
  document.getElementById("aboutText").innerText = t.aboutText;
  document.getElementById("listen").innerText = t.listen;
  document.getElementById("contactTitle").innerText = t.contactTitle;
  document.getElementById("contactText").innerText = t.contactText;
}
