class Value{
   String sender,receiver,needed;
   Value(this.sender,this.receiver,this.needed);
}

List<String> areaDimensions=["sq ft","sq m","sq km"];

//New categories 0627146668
List<String> houseOrLand=["Jengo/Nyumba","Eneo la ardhi"];
List<String> propertyPurpose=["Biashara","Makazi"];
List<String> rentalSize=["Jengo zima(familia moja tu)","Sehemu ya jengo(familia nyingi)"];
//ResidentBuild
List<String> residentBuildingStatus=["Jipya","Limetumika","Lipo kwenye ujenzi(pagale)","Ujenzi umesimama"];
List<String> residentBuildingTypes=["Apartment","Bungalow","Condo","Villa","Duplex","Triplex","Fourplex","House(Nyumba ya kawaida)","Studio apartment","Chalet","Terrace","Penthouse","Mansion","Maisonatte"];
List<String> residentBuildingMeaning=[
  "Ni jengo au sehemu/patishen ya jengo  inayojitosheleza kwa maisha ya familia au mtu mmoja mmoja.\n Maranyingi hua katika jengo la ghorofa na choo na bafu hua ndani yake",
  "Ni nyumba yenye sakafu moja tu na nafasi/uwazi mkubwa sehemu ya dali ambayo inaweza kua na vyumba pia \n Hua na madirisha makubwa yaliyo karibu na ardhi. \n Hua na paa lenye muinuko/mlalo mdogo",
  "Ni apartment iliyo chini ya mmiliki mmoja ambaye hana umiliki wa jengo zima(anamiliki sehemu tuu na anamamlaka mazima ya namna ya kuiendesha condo hiyo) \n Vigezo vingine ni sawa na vile vya apartment",
  "Ni nyumba kubwa ya kifahari iliyo kwenye ardhi yake yenyewe na inajitosheleza kwa vitu vya starehe kama gadeni, swimming pool, eneo la mazoezi n.k \n Mmili wa villa anamiliki na eneo la ardhi chini ya villa \n Mara nyingi hua karibu na bahari na hua na ghorofa moja.", 
  "Ni nyumba mbili zilizoungana kwa pembeni au moja juu ya ingine zisizokua na muingiliano baina yao(Kila moja ina mlango wa kutoka nje)", 
  "Ni nyumba tatu zilizoungana kwa pembeni au moja juu ya ingine zisizokua na muingiliano baina yao(Kila moja ina mlango wa kutoka nje)",
  "Ni nyumba nne zilizoungana kwa pembeni au moja juu ya ingine zisizokua na muingiliano baina yao(Kila moja ina mlango wa kutoka nje)",
  "Ni nyumba ya kawaida ya mtaani yenye hali ya katikati kushuka chini \n Haina tofauti na nyumba nyingi tulizozizoea",
  "Ni makazi ya chumba kimoja kikubwa kinachoweza kugawanywa na kupata vyumba vingine isipokua maranyingi choo na bafu hua pekeyake \n Baadhi ya studio apartment hua na viukuta vifupi vinavyotenganisha vyumba",
  "Ni nyumba ya kuta za mbao yenye paa lenye muinuko mkali, mara nyingi hua maeneo ya baridi kali na mapaa yake hayaruhusu barafu kuganda juu.",
  "Ni nyuma zinazofanana zilizo ungana upande kwa upande katika mstari mmoja",
  "Ni apartment ya kifahari sana ambayo hua katika ghorofa ya mwisho kabisa(top floor) ya jengo zima",
  "Ni jumba la kifahari liliyo chukua eneo kubwa sana ardhi( zaidi ya futi za mraba 5000) na hua na angalau vyumba 5 au 6",
  "Ni nyumba ya ghorofa moja ambapo kila patishen inamlango wake wa kwenda nje."
];
//CommercialBuild
List<String> creBuildingClasses=["Class A","Class B","Class C"];
List<String> commercialBuildingTypes=["Retail(duka size yoyote)","Multifamily(kwa kuishi)","Office","Industry(kiwanda)","Hospitality"];
   //Hospitality
   Map<String,dynamic> commercialSubBuilding={
    "0":[],
    "1":["Garden apartment","Mid-rise apartment","High-rise apartment","Student housing/dorms","Senior and assisted living"],
    "2":[],
    "3":["Heavy manufacturing","Light manufacturing/assembly plants","Warehouse(ghala)","Flex spaces(kiwanda na ofisi)"],
    "4":["Full service hotel","Limited service hotel","Extended stay hotel","Casino","Boutique","Resort"]   
   };


//End of new categories


List<String> userRoleChoices=["Dalali","Mmiliki"];
List<String> rentalType=["Fremu ya biashara","Nyumba ya kuishi","Jengo la ofisi","Godown(Stoo)"];
List<String> distanceFrmRoadChoices=["Mkabala na barabara(Hakuna kizuizi)","Ndani ya hatua 50","Ndani ya hatua 100","Nje ya hatua 100"];
List<String> buildingElectricity=["Sio wakushea","Wakushea na wengine","Haupo"];
List<String> buildingCompletionStatusChoices=["Limekamilika","linamalizikia","Lipo kwenye ujenzi","Ujenzi umesimama(pagale)"];
List<String> buildingWaterStatusChoices=["Ndani ya pango","Ndani ya hatua 50","Ndani ya hatua 100","Nje ya hatua 100"];
List<String> payCurrencyChoices=["USD","TSH","EURO"];
List<String> payPeriodChoices=["/Siku","/Wiki","/Mwezi","/Mwaka"];
List<String> payPeriodChoicesPrural=["Siku","Wiki","Miezi","Miaka"];
List<String> buildingTypeChoices=["Jengo la ghorofa","Jengo la kawaida(sio ghorofa)"];
List<String> buildingAssetStatus=["Haina vitu","Ina vitu"];

List<String> toiletStatusChoices=["Binafsi","Cha kushea na wengine"];
List<String> parkingStatusChoices=["Eneo la paking lipo","Eneo la paking halipo"];
List<String> fensStatusChoices=["Ina uzio","Haina uzio"];

List<String> insideSocialServices =[
"Duka",
"Shoping mall",
"Lift ya umeme",
"Swimming pool",
"Gym",
"Viwanja vya michezo",
"AC",
"Fensi ya umeme",
"CCTV camera",
"Sapoti kwa wasiojiweza eg wazee"
];

List<String> nearbySocialServices =[
"Shule ya awali",
"Shule ya msingi",
"Shule ya sekondari",
"Chuo cha kati",
"Chuo kikuu",
"Stendi ya mabasi",
"Soko",
"Kituo cha afya",
"Hoteli",
"Kisima",
"Barabara",
"Mgahawa",

];


List<Map<String,dynamic>> helpCategories=[
  {
    "title":"Vitu unavyoweza kufanya ndani ya betterhouse",
    "content":[
      "Kutafuta jengo(nyumba,ofisi,stoo) ya kununua au kupanga kwa vigezo unavyovitaka. viwanja na mashamba vitahusishwa kwenye toleo lijalo",
      "Kuwasiliana na mmiliki au dalali wa jengo/nyumba husika kwa njia ya meseji au kumpigia hadi utakapo fanikisha kupata hitaji lako",
      "Kutangaza jengo lako(baada ya kujisajili) ili kupata mnunuaji au mpangaji kwa kujaza taarifa za jengo",
      "Kupata taarifa ya watu walioona tangazo lako"
    ]
  },
  {
    "title":"Namna ya kujisajili",
    "content":[
      "Bonyeza kitufe cha kujisajili na ujaze taarifa zako sahihi, ni muhimu kujaza na baruapepe(email) pia kama unayo itasaidia kua mbadala wa njia ya kuingia betterhouse",
      "Jaza namba ya simu kwa kuanzia tarakimu ya pili, mfano kama namba inaaza na 07xxxxxx wewe anza na 7xxxxxx",
      "Kamilisha usajili kwa kujaza tarakimu 6 tutakazo kutumia kwa njia ya meseji ili kuthibitisha umiliki wa namba ya simu", 
      "Hongera usajili umekamilika na hapo unaweza endelea na matumizi"
    ]
  },
  {
    "title":"Kutangaza jengo lako",
    "content":[
      "Bonyeza kitufe cha kujisajili na ujaze taarifa zako sahihi, ni muhimu kujaza na baruapepe(email) pia kama unayo itasaidia kua mbadala wa njia ya kuingia betterhouse",
      "Jaza namba ya simu kwa kuanzia tarakimu ya pili, mfano kama namba inaaza na 07xxxxxx wewe anza na 7xxxxxx",
      "Kamilisha usajili kwa kujaza tarakimu 6 tutakazo kutumia kwa njia ya meseji ili kuthibitisha umiliki wa namba ya simu", 
      "Hongera usajili umekamilika na hapo unaweza endelea na matumizi"
    ]
  },
];
