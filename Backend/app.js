const express = require('express');//import express
const body_parser = require('body-parser');
const userRouter = require ("./routers/user.router");

const app =express();//variable to import express and express will be a function

app.use(body_parser.json());

app.use("/",userRouter);

module.exports = app;//used to export app.js in other file

