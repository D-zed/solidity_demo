// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

contract Structs {

    struct Car{
        string model;
        uint year;
        address owner;
    }

    Car public car;
    Car[] public cars;
    mapping (address=>Car[]) public carsByOwner;
    function examples() external returns(string memory,uint,address){
        Car memory toyota=Car("Toyota",2015,msg.sender);
        Car memory lambo= Car({year:1980,model:"lamboghini",owner:msg.sender});
        Car memory tesla;
        tesla.model="tesla";
        tesla.year=2010;
        tesla.owner=msg.sender;
        cars.push(toyota);
        cars.push(lambo);
        cars.push(tesla);
        cars.push(Car("Ferrari",2020,msg.sender));
        delete cars[0]; // 将0位置的Cars的属性职位初始值
        Car memory _car= cars[0];
        // delete _car.owner; //置为默认值
        // delete _car.model; 
        return (_car.model,_car.year,_car.owner);
    }

}