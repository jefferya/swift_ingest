-- check that DB exits
CREATE DATABASE IF NOT EXISTS swift_ingest;

-- use DB
use swift_ingest;

-- (re)create tables

-- archiveEvent
drop table if exists swift_ingest.archiveEvent;
CREATE TABLE `archiveEvent`
( `id`            int(10) unsigned NOT NULL AUTO_INCREMENT,
  `project`        varchar(64)      NOT NULL,
  `container`     varchar(64)      NOT NULL,
  `ingestTime`    datetime         NOT NULL,
  `objectIdentifier`      varchar(64)      NOT NULL,
  `objectChecksum`  varchar(64)      NOT NULL,
  `objectSize`      int(11) unsigned NOT NULL,
    PRIMARY KEY (`ID` )
) ENGINE=MyISAM  DEFAULT CHARSET=latin1;

-- customMetadata
drop table if exists swift_ingest.customMetadata;
CREATE TABLE `customMetadata`
( `eventId`       int(10) unsigned NOT NULL,
  `propertyName`          varchar(64)  DEFAULT NULL,
  `propertyValue`         varchar(64)  DEFAULT NULL,
  INDEX event_ind (eventId),
  FOREIGN KEY (eventId)
    REFERENCES ArchiveEvent(id)
    ON DELETE CASCADE
) ENGINE=MyISAM  DEFAULT CHARSET=latin1;
