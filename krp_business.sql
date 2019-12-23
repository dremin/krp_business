-- phpMyAdmin SQL Dump
-- version 4.6.6deb5
-- https://www.phpmyadmin.net/
--
-- Host: localhost:3306
-- Generation Time: May 03, 2019 at 02:57 AM
-- Server version: 10.1.38-MariaDB-0ubuntu0.18.04.1
-- PHP Version: 7.2.17-0ubuntu0.18.04.1

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `essentialmode`
--

-- --------------------------------------------------------

--
-- Table structure for table `businesses`
--

CREATE TABLE `businesses` (
  `id` int(11) NOT NULL,
  `label` varchar(255) NOT NULL,
  `location` varchar(255) NOT NULL,
  `price` int(11) NOT NULL,
  `earnings` int(11) NOT NULL,
  `owner` varchar(100) DEFAULT NULL,
  `lastPayout` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `defaultLabel` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `businesses`
--

INSERT INTO `businesses` (`id`, `label`, `location`, `price`, `earnings`, `owner`, `lastPayout`, `defaultLabel`) VALUES
(1, 'Beach Bar', '{\"x\":-2081.6,\"y\":-503.23,\"z\":11.1}', 60000, 500, NULL, '2019-05-03 00:52:58', 'Beach Bar'),
(2, 'Vanilla Unicorn', '{\"x\":126.01,\"y\":-1306.86,\"z\":28.3}', 900000, 500, NULL, '2019-05-03 00:52:58', 'Vanilla Unicorn'),
(3, 'Stab City', '{\"x\":74.34,\"y\":3643.56,\"z\":38.55}', 65000, 500, NULL, '2019-05-01 00:52:58', 'Stab City'),
(4, 'Los Santos Autos', '{\"x\":-379.65,\"y\":-122.29,\"z\":37.69}', 600000, 1500, NULL, '2019-05-01 00:52:58', 'Los Santos Autos'),
(5, 'Pacific Standard Bank', '{\"x\":231.34,\"y\":211.24,\"z\":104.46}', 9000000, 7000, NULL, '2019-05-01 00:52:58', 'Pacific Standard Bank'),
(6, 'Los Santos Import Autos', '{\"x\":-360.34,\"y\":-91.49,\"z\":44.66}', 900000, 3000, NULL, '2019-05-01 00:52:58', 'Los Santos Import Autos'),
(7, 'Bahama Mama Bar', '{\"x\":-1391.42,\"y\":-587.14,\"z\":29.24}', 90000, 1000, NULL, '2019-05-01 00:52:58', 'Bahama Mama Bar'),
(8, 'Yellow Jack Bar', '{\"x\":1994.03,\"y\":3052.98,\"z\":46.21}', 90000, 1000, NULL, '2019-05-01 00:52:58', 'Yellow Jack Bar'),
(9, 'Galaxy Modern Bar', '{\"x\":194.65,\"y\":-3165.25,\"z\":4.79}', 90000, 1000, NULL, '2019-05-01 00:52:58', 'Galaxy Modern Bar'),
(10, 'Los Santos Muesem', '{\"x\":-558.63,\"y\":-626.04,\"z\":33.68}', 120000, 2000, NULL, '2019-05-01 00:52:58', 'Los Santos Muesem'),
(11, 'Chilliad Weed Farm', '{\"x\":-1135.12,\"y\":4946.23,\"z\":221.27}', 220000, 3000, NULL, '2019-05-01 00:52:58', 'Chilliad Weed Farm'),
(12, 'The Lost Club', '{\"x\":981.15,\"y\":-104.64,\"z\":73.85}', 565000, 4000, NULL, '2019-05-01 00:52:58', 'The Lost Club');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `businesses`
--
ALTER TABLE `businesses`
  ADD PRIMARY KEY (`id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `businesses`
--
ALTER TABLE `businesses`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=13;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
