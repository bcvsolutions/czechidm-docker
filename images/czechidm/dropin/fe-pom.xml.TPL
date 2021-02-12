<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
	<modelVersion>4.0.0</modelVersion>
	<groupId>eu.bcvsolutions.idm</groupId>
	<artifactId>idm-app</artifactId>
	<version>1.0.0</version>
	<packaging>pom</packaging>
	<name>CzechIdM Application</name>
	<description>CzechIdM web application for tool usage only - frontend is build and copied into war folder.</description>

	<build>
		<plugins>
		    <plugin>
				<groupId>org.bsc.maven</groupId>
				<artifactId>maven-processor-plugin</artifactId>
				<version>3.3.3</version>
				<executions>
					<execution>
						<id>process</id>
						<goals>
							<goal>process</goal>
						</goals>
						<phase>generate-sources</phase>
						<configuration>
							<!-- source output directory -->
							<outputDirectory>target/metamodel</outputDirectory>
						</configuration>
					</execution>
				</executions>
			</plugin>
			<plugin>
				<groupId>com.github.eirslett</groupId>
				<artifactId>frontend-maven-plugin</artifactId>
				<version>1.10.0</version>
				<configuration>
					<workingDirectory>./frontend/fe-sources</workingDirectory>
					<installDirectory>${node.home}</installDirectory>
					<downloadRoot>https://repo.iamappliance.com/repository/binary-public/node/</downloadRoot>
				</configuration>
				<executions>
					<execution>
						<id>install node and npm</id>
						<goals>
							<goal>install-node-and-npm</goal>
						</goals>
						<phase>generate-resources</phase>
						<configuration>
							<nodeVersion>v12.16.3</nodeVersion>
							<npmVersion>6.14.4</npmVersion>
						</configuration>
					</execution>
					<execution>
						<id>app npm install</id>
						<goals>
							<goal>npm</goal>
						</goals>
						<phase>generate-resources</phase>
						<configuration>
							<arguments>install</arguments>
						</configuration>
					</execution>
					<!-- gulp install build all product modules together -->
					<execution>
						<id>app gulp install</id>
						<goals>
							<goal>gulp</goal>
						</goals>
						<phase>generate-resources</phase>
						<configuration>
							<arguments>install</arguments>
						</configuration>
					</execution>
					<execution>
						<id>gulp build</id>
						<goals>
							<goal>gulp</goal>
						</goals>
						<phase>generate-resources</phase>
						<configuration>
							<arguments>build -p default -s production --max_old_space_size=16384 --max-old-space-size=16384 -max-old-space-size=16384</arguments>
							<workingDirectory>./frontend/fe-sources</workingDirectory>
							<installDirectory>${node.home}</installDirectory>
						</configuration>
					</execution>
				</executions>
			</plugin>
			<plugin>
				<artifactId>maven-resources-plugin</artifactId>
				<version>3.0.1</version>
				<executions>
					<execution>
						<id>copy-resources</id>
						<phase>prepare-package</phase>
						<goals>
							<goal>copy-resources</goal>
						</goals>
						<configuration>
							<outputDirectory>./war</outputDirectory>
							<resources>
								<resource>
									<directory>./frontend/fe-sources/dist</directory>
									<filtering>false</filtering>
								</resource>
							</resources>
						</configuration>
					</execution>
				</executions>
			</plugin>
		</plugins>
	</build>

	<profiles>
		<profile>
			<id>release</id>
			<activation>
				<activeByDefault>true</activeByDefault>
			</activation>
		</profile>
	</profiles>
</project>

