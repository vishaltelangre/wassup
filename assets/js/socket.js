import {Socket} from "phoenix";

let socket;
const { userToken } = App;

if (userToken) {
  socket = new Socket("/socket", { params: { token: userToken } })

  socket.connect();
}

export default socket;
