-- Main sql file

CREATE DATABASE omicron;

CREATE TABLE IF NOT EXISTS `omicron`.`user` (
  `id` int(5) NOT NULL AUTO_INCREMENT,
  `login` varchar(100) NOT NULL,
  `password` varchar(33) NOT NULL,
  `name` varchar(50) NOT NULL,
  `createdate` date NOT NULL DEFAULT '0000-00-00',
  `email` varchar(100) NOT NULL,
  `status` int(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 AUTO_INCREMENT=10;

INSERT INTO `omicron`.`user` (`id`, `login`, `password`, `name`, `createdate`, `email`, `status`) VALUES
(100, 'dopiet', 'e13b23dca87dea3378becc34cc513f50', 'Tomasz Dopierała', '2010-02-01', 'dopierala.tomasz@wp.pl', 1);