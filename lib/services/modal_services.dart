
class RentalModel{
  Map<String,dynamic> rental;
  RentalModel(this.rental);
}

class Message{
  var id,rentalId,sender,receiver,message,seenStatus,time,date;
  Message(this.id,this.rentalId,this.sender,this.receiver,this.message,this.seenStatus,this.time,this.date);
}

class RentalFoundNotificationModal{
 var id,matchingRental,user,requestId,time,status;
 RentalFoundNotificationModal(this.id,this.matchingRental,this.user,this.requestId,this.time,this.status);
}

class CommercialBuilding{
var buildingClass,buildingType,subBuildingType;
 CommercialBuilding(this.buildingClass,this.buildingType,this.subBuildingType);

}

class ResidentBuilding{
var buildingType,buildingStatus,bedRooms,livingRooms,diningRooms,kitchenRooms,storeRooms,selfRoomsbathRooms,bathRooms;

 ResidentBuilding(this.buildingType,this.buildingStatus,this.bedRooms,this.livingRooms,this.diningRooms,this.kitchenRooms,this.storeRooms,this.selfRoomsbathRooms,this.bathRooms);
}

class PropertyInfo{
  Map<String,dynamic>? ownerInfo;
  List? insideServices,socialServices;
  var specificInfo;
  var operation,userRole,id,
  houseOrLand,purpose,hasFens,hasParking,areaDimension,areaSize,brokerPayCurrency,brokerSalary,
  userId,internalViews,likes,payCurrency,
  buildingBillAmount,minBillPeriod,billPeriodsNumber,propertyPriceAmount,
  imageCount,coverImage,
  country,region,regionName,district,districtName,localArea,latlong,title,suspended,suspensionReason,partSize,sold;
  DateTime? uploadTime;
  
  PropertyInfo({
  this.id,this.ownerInfo,
  this.specificInfo,
  this.operation,this.userRole,
  this.title,this.suspended,this.suspensionReason,this.partSize,this.sold,this.houseOrLand,this.purpose,this.hasFens,this.hasParking,this.areaDimension,this.areaSize,this.socialServices,this.brokerPayCurrency,this.brokerSalary,
  this.userId,this.internalViews,this.likes,this.payCurrency,
  this.buildingBillAmount,this.minBillPeriod,this.billPeriodsNumber,this.propertyPriceAmount,
  this.imageCount,this.coverImage,
  this.country,this.region,this.regionName,this.district,this.districtName,this.localArea,this.latlong,this.insideServices
  ,this.uploadTime
  });

 PropertyInfo initializeData(var data){
  return PropertyInfo(
             id:data["id"],
             ownerInfo:data["ownerInfo"],
             specificInfo:data["houseOrLand"]==0 && data["purpose"]==0?
             CommercialBuilding(data["buildingClass"], data["buildingType"],data["subBuildingType"]):
            data["houseOrLand"]==0 && data["purpose"]==1?
             ResidentBuilding(data["buildingType"], data["buildingStatus"],data["bedRooms"] ,data["livingRooms"] ,data["diningRooms"] ,data["kitchenRooms"] ,data["storeRooms"] ,data["selfRooms"],data["bathRooms"]) :PropertyInfo(),
             operation:data["operation"],
             userRole:data["userRole"],
             title:data["title"],
             suspended:data["suspended"],
             suspensionReason:data["suspensionReason"],
             partSize:data["rentalSize"],
             sold:data["sold"],
             houseOrLand:data["houseOrLand"],
             purpose:data["purpose"],
             hasFens:data["hasFens"],
             hasParking:data["hasParking"],
             areaDimension:data["areaDimension"],
             areaSize:data["areaSize"],
             socialServices:data["socialServices"],
             brokerPayCurrency:data["brokerPayCurrency"],
             brokerSalary:data["brokerSalary"],
             userId:data["userId"],
             internalViews:data["internalViews"],
             likes:data["likes"],
             payCurrency:data["payCurrency"],
             buildingBillAmount:data["buildingBillAmount"],
             minBillPeriod:data["minBillPeriod"],
             billPeriodsNumber:data["billPeriodsNumber"],
             propertyPriceAmount:data["propertyPriceAmount"],
             imageCount:data["imageCount"],
             coverImage:data["coverImage"],
             country:data["country"],
             region:data["region"],
             regionName:data["regionName"],
             district:data["district"],
             districtName:data["districtName"],
             localArea:data["localArea"],
             latlong:data["latlong"],
             insideServices:data["insideServices"],
             uploadTime: data["uploadTime"].toDate()
            );
 }

}

class UserComment{
   var id,commenterId,name,photo,ownerId,comment,star,time;
  UserComment(this.id,this.commenterId,this.name,this.photo,this.ownerId,this.comment,this.star,this.time);
}

class ChatRoom{
   var personName,chatRoomId,smsId,message,sender,receiver,rentalId,seenStatus,time,unseenSms,profilePhoto;
  ChatRoom(this.personName,this.chatRoomId,this.smsId,this.message,this.sender,this.receiver,this.rentalId,this.seenStatus,this.time,this.unseenSms,this.profilePhoto);
}

class HelpCategories{
  String title;
  List content;
  HelpCategories(this.title,this.content);
}

