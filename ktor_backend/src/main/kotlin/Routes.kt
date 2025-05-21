package com.example

import Room
import com.example.utils.ServerUtils
import io.ktor.http.*
import io.ktor.server.application.*
import io.ktor.server.response.*
import io.ktor.server.routing.*
import io.ktor.server.websocket.*
import java.util.concurrent.ConcurrentHashMap

fun Application.configureRoutes(rooms: ConcurrentHashMap<Int, Room>) {

    routing {
        // HTTP route to create room
        get("/create-room") {
            val roomId = generateUniqueRoomId(rooms)
            println("Room with $roomId is created")
            call.respond(mapOf("roomId" to roomId))
        }

        // HTTP route to validate and join a room
        get ("/join-room/{roomId}") {
            val roomIdParam = call.parameters["roomId"]
            val roomId = roomIdParam?.toIntOrNull()

            when {
                roomIdParam == null -> call.respond(HttpStatusCode.BadRequest, "Missing Room ID")
                roomId == null -> call.respond(HttpStatusCode.BadRequest, "Invalid Room ID")
                !rooms.containsKey(roomId) -> call.respond(HttpStatusCode.NotFound, "Room not found")
                else -> call.respond(HttpStatusCode.OK, "Room available")
            }
        }

        // SINGLE WebSocket route used by both creator and joiner
        webSocket("/play/{roomId}") {
            handleWebSocketSession(this, rooms)
        }
    }
}


private fun generateUniqueRoomId(rooms: ConcurrentHashMap<Int, Room>): Int {
    var roomId: Int
    do {
        roomId = ServerUtils.generateUUID()
    } while (rooms.contains(roomId))
    return roomId
}
