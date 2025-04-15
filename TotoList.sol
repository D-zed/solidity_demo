// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

// insert update, read from array of structs
contract TotoList {
    struct Todo{
        string text;
        bool completed;
    }

    Todo[] public todos;

    function create(string calldata _text) external {
        todos.push(Todo(_text, false));
    }
    
    function udpateText(uint _index,string calldata _text) external {
        todos[_index].text = _text;
    }
    //更加节省gas的方式 尤其是更新多个的时候
    function udpate(uint _index,string calldata _text) external {
        Todo storage toto= todos[_index];
        toto.text = _text;
    }

    //read todo from array of structs
    function get(uint _index) public view returns (string memory){
        return todos[_index].text;
    }

    function toggleCompleted(uint _index) external {
        todos[_index].completed=!todos[_index].completed;
    }
}