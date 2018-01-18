# SWIFT ingest Ruby gem
Ruby gem for storing files in swift openstack storage

![Ruby Swift Ingest gem Diagram](docs/images/overview.png)

## Requirements

Swift_Ingest supports Ruby 2.3.1+

## Installation

Swift_Ingest is hosted on rubygems.org. Therefore it can be installed via:

```bash
  gem install swift_ingest
```

## Usage

This gem in indented to be used from other ruby programs.
Typical usage involves creating new SwiftIngest object

```bash
  swift_depositer = SwiftIngest::Ingestor.new(username: 'swift_user'
                                              password: 'swift_password'
                                              tenant: 'swift_tenant'
                                              auth_url: 'http://www.example.com:8080/auth/v1.0',
                                              project_name: 'swift_project_name'
                                              project_domain_name: 'swift_project_domain_name'
                                              project: 'project_name')

```
last parameter 'project_name' is project that will be stored in swift metadata and in database 'project' field.

Use newly created object to deposit object into swift repository:

```bash
  swift_depositer.deposit_file(myfile_file, 'MY_CONTAINER', options)
```
First parameter is the name of the file that will be deposited in the swift,
second parameter is the SWIFT container that file will be deposited into, and the
last parameter 'options' is hash table that contains custom data that will be stored in
database.
For example, if 'options' set to: last_mod_timestamp: '2017-01-01 12:00:00', gem will store
'last_mod_timestamp' value in 'propertyName' field and '2017-01-01 12:00:00' in 'propertyValue' field

### Logging into mysql database

Gem will try to connect mysql database and log preservation events into the database.
There are two tables defined:

```bash
archiveEvent
+------------------+------------------+------+-----+---------+----------------+
| Field            | Type             | Null | Key | Default | Extra          |
+------------------+------------------+------+-----+---------+----------------+
| id               | int(10) unsigned | NO   | PRI | NULL    | auto_increment |
| project          | varchar(64)      | NO   |     | NULL    |                |
| container        | varchar(64)      | NO   |     | NULL    |                |
| ingestTime       | datetime         | NO   |     | NULL    |                |
| objectIdentifier | varchar(64)      | NO   |     | NULL    |                |
| objectChecksum   | varchar(64)      | NO   |     | NULL    |                |
| objectSize       | int(11) unsigned | NO   |     | NULL    |                |
+------------------+------------------+------+-----+---------+----------------+

customMetadata
+---------------+------------------+------+-----+---------+-------+
| Field         | Type             | Null | Key | Default | Extra |
+---------------+------------------+------+-----+---------+-------+
| eventId       | int(10) unsigned | NO   | MUL | NULL    |       |
| propertyName  | varchar(64)      | YES  |     | NULL    |       |
| propertyValue | varchar(64)      | YES  |     | NULL    |       |
+---------------+------------------+------+-----+---------+-------+
```
Data passed in option hash parameter (see above) will be stored in customMedatata table.
Gem will look at UNIX environment variables:
DB_HOST DB_USER DB_PASSWORD DB_DATABASE
If all these variables defined, gem will try to connect to the database and
will log every preservation event.


## Testing

To run the test suite:

```bash
  bundle install
  bundle exec rake
```

This will run both rspec and rubocop together.

To run rspec by itself:

```bash
  bundle exec rspec
```
To run rubocop by itself:

```bash
  bundle exec rubocop
```
