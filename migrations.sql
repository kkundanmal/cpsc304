CREATE TABLE `Location` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `name` char(100) NOT NULL DEFAULT '',
  `address` char(100) NOT NULL DEFAULT '',
  `phone` char(15) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `address` (`address`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;





CREATE TABLE `User` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `email` char(100) NOT NULL,
  `name` char(100) NOT NULL DEFAULT '',
  `phone` char(15) NOT NULL DEFAULT '',
  `address` char(100) NOT NULL DEFAULT '',
  PRIMARY KEY (`id`),
  UNIQUE KEY `email` (`email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;





CREATE TABLE `Employee` (
  `user_id` int(11) unsigned NOT NULL,
  `location_id` int(11) unsigned NOT NULL,
  `salary` decimal(10,2) NOT NULL,
  PRIMARY KEY (`user_id`),
  KEY `EmployeeLocation` (`location_id`),
  CONSTRAINT `Employee` FOREIGN KEY (`user_id`) REFERENCES `User` (`id`) ON DELETE NO ACTION ON UPDATE CASCADE,
  CONSTRAINT `EmployeeLocation` FOREIGN KEY (`location_id`) REFERENCES `Location` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;




CREATE TABLE `Customer` (
  `user_id` int(11) unsigned NOT NULL,
  PRIMARY KEY (`user_id`),
  CONSTRAINT `Customer` FOREIGN KEY (`user_id`) REFERENCES `User` (`id`) ON DELETE NO ACTION ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;




CREATE TABLE `InventoryCategory` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `name` char(100) NOT NULL DEFAULT '',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;




CREATE TABLE `InventoryItem` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `name` char(100) NOT NULL DEFAULT '',
  `description` char(100) DEFAULT NULL,
  `price` decimal(10,2) NOT NULL,
  `type_id` int(11) unsigned NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;

CREATE TABLE `PurchaseRecord` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `date` datetime NOT NULL,
  `isreturned` tinyint(1) NOT NULL,
  `payee_id` int(11) unsigned NOT NULL,
  `cashier_id` int(11) unsigned NOT NULL,
  PRIMARY KEY (`id`),
  KEY `PayeeId` (`payee_id`),
  KEY `Cashier` (`cashier_id`),
  CONSTRAINT `Cashier` FOREIGN KEY (`cashier_id`) REFERENCES `Employee` (`user_id`) ON DELETE NO ACTION ON UPDATE CASCADE,
  CONSTRAINT `PayeeId` FOREIGN KEY (`payee_id`) REFERENCES `Customer` (`user_id`) ON DELETE NO ACTION ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


CREATE TABLE `Stock` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `inventoryitem_id` int(11) unsigned NOT NULL,
  `location_id` int(11) unsigned NOT NULL,
  `purchaserecord_id` int(11) unsigned DEFAULT NULL,
  `purchaseprice` decimal(10,2) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `Location` (`location_id`),
  KEY `PurchaseRecord` (`purchaserecord_id`),
  KEY `InventoryItem` (`inventoryitem_id`),
  CONSTRAINT `InventoryItem` FOREIGN KEY (`inventoryitem_id`) REFERENCES `InventoryItem` (`id`),
  CONSTRAINT `Location` FOREIGN KEY (`location_id`) REFERENCES `Location` (`id`) ON DELETE NO ACTION ON UPDATE CASCADE,
  CONSTRAINT `PurchaseRecord` FOREIGN KEY (`purchaserecord_id`) REFERENCES `PurchaseRecord` (`id`) ON DELETE NO ACTION ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


CREATE TABLE `Review` (
  `customer_id` int(11) unsigned NOT NULL,
  `inventoryitem_id` int(11) unsigned NOT NULL,
  `date` datetime NOT NULL,
  `rating` decimal(5,4) NOT NULL,
  `text` mediumtext DEFAULT NULL,
  PRIMARY KEY (`customer_id`,`inventoryitem_id`),
  KEY `ItemId` (`inventoryitem_id`),
  CONSTRAINT `CustomerId` FOREIGN KEY (`customer_id`) REFERENCES `Customer` (`user_id`) ON DELETE NO ACTION ON UPDATE CASCADE,
  
CONSTRAINT `ItemId` FOREIGN KEY (`inventoryitem_id`) REFERENCES `InventoryItem` (`id`) ON DELETE NO ACTION ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;





-- ...check if PurchaseRecord is having a sold item within Stock table before inserting a tuple to PurchaseRecord table.

-- If condition is failed we set null to primary key to set constraint error.
CREATE TRIGGER `purchaserecord_totalparticipation_stock`
BEFORE INSERT ON PurchaseRecord
FOR EACH ROW
   SET NEW.id = IF(
	(EXISTS	(
		SELECT *
		FROM Stock s
		WHERE s.purchaserecord_id = NEW.id
		)
	),
	NEW.id,
	NULL
   );


-- ...check if newly added sold stock is not null sold price.
-- If condition is failed we set null to primary key to set constraint error.
CREATE TRIGGER `stock_notnull_soldatupdate`
BEFORE UPDATE ON Stock
FOR EACH ROW
   SET NEW.id = IF(
	(NEW.purchaserecord_id IS NOT NULL AND NEW.purchaseprice IS NULL),
	NULL,
	NEW.id
   );


-- ...check if sold Stock tuple is with a sold price
-- If condition is failed we set null to primary key to set constraint error.
CREATE TRIGGER `stock_notnull_soldatinsert`
BEFORE INSERT ON Stock
FOR EACH ROW
   SET NEW.id = IF(
	(NEW.purchaserecord_id IS NOT NULL and NEW.purchaseprice IS NULL),
	NULL,
	NEW.id
   );
