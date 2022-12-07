import subprocess
from utils.remote_cmd import get_remote_cmd, get_remote_cmd_sudo
from stacks.stack import Stack

class Udp(Stack):
    NAME = "udp"
    B10 = "10M"
    B25 = "25M"
    B50 = "50M"

    def __init__(self, server_ip, server_hostname, server_pw_path):
        self.server_ip = server_ip
        self.server_hostname = server_hostname
        self.server_pw_path = server_pw_path

    def run_remote_server(self, port_no, cc_algo, duration_s):
        cmd = self.run_server_cmd(port_no, cc_algo, duration_s)
        cmd = get_remote_cmd(self.server_hostname, cmd)
        return subprocess.Popen(cmd)

    def run_remote_server_wlogs(self, port_no, cc_algo, duration_s, log_path):
        cmd = self.run_server_cmd_wlogs(port_no, cc_algo, duration_s, log_path)
        cmd = get_remote_cmd_sudo(self.server_hostname, self.server_pw_path, " ".join(cmd))
        return subprocess.Popen(cmd, shell=True)

    def run_client(self, port_no, cc_algo, duration_s):
        cmd = self.run_client_cmd(port_no, cc_algo, duration_s)
        return subprocess.Popen(cmd)

    def run_server_cmd(self, port_no, cc_algo, duration_s):
        return map(str, [
            "timeout", duration_s,
            "iperf3", "-s", "-p", port_no, "-1", "-i", "60"
        ])

    def run_server_cmd_wlogs(self, port_no, cc_algo, duration_s, log_path):
        raise RuntimeError("run_server_cmd_wlogs() is not currently defined for ")

    def run_client_cmd(self, port_no, cc_algo, duration_s):
        return map(str, [
            "iperf3", "-c", self.server_ip, "-p", port_no,
            "-t", duration_s, "--bidir", "-i", "60", "-u", "-b", cc_algo
        ])

    @staticmethod
    def get_cc_algos():
        return [Udp.B10, Udp.B25, Udp.B50]
