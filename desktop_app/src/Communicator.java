import com.ericsson.otp.erlang.*;

import java.io.IOException;

public class Communicator {

    private String serverNodeName;
    private String selfNodeName;

    private boolean connected;

    private OtpConnection connection;

    public Communicator(String serverNodeName, String selfNodeName) {
        this.serverNodeName = serverNodeName;
        this.selfNodeName = selfNodeName;
        this.connected = false;
    }

    boolean connectToServer() {
        if (!connected) {
            OtpSelf self;
            OtpPeer server;
            try {
                self = new OtpSelf(selfNodeName);
                server = new OtpPeer(serverNodeName);
            } catch (IOException e) {
                e.printStackTrace();
                return false;
            }
            self.setCookie(server.cookie());
            try {
                connection = self.connect(server);
            } catch (Exception e) {
                e.printStackTrace();
                return false;
            }
            connected = true;
        }
        return true;
    }

    public int[] getCurrency() {
        int[] res = new int[2];
        res[0] = -1;

        try {
            connection.sendRPC("bank_server", "getCurrency", new OtpErlangList());
        } catch (IOException e) {
            e.printStackTrace();
            return res;
        }

        OtpErlangTuple received;
        try {
            received = (OtpErlangTuple) connection.receiveRPC();
        } catch (Exception e) {
            e.printStackTrace();
            return res;
        }

        if (!received.toString().contains("badrpc")) {
            res[0] = Integer.valueOf(received.elementAt(0).toString());
            res[1] = Integer.valueOf(received.elementAt(1).toString());
        } else {
            System.err.println(received);
        }

        return res;
    }

}
