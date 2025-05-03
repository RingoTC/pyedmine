import json
import os
import inspect

from edmine.config.data import config_q_table, config_cd_dataset
from edmine.config.basic import config_logger
from edmine.config.model import config_general_dl_model
from edmine.config.train import config_epoch_trainer, config_optimizer
from edmine.config.train import config_wandb
from edmine.data.FileManager import FileManager
from edmine.utils.log import get_now_time
from edmine.utils.data_io import save_params, read_csv


current_file_name = inspect.getfile(inspect.currentframe())
current_dir = os.path.dirname(current_file_name)
settings_path = os.path.join(current_dir, "../../../settings.json")
with open(settings_path, "r") as f:
    settings = json.load(f)
FILE_MANAGER_ROOT = settings["FILE_MANAGER_ROOT"]
MODELS_DIR = settings["MODELS_DIR"]
    

def config_hier_cdf(local_params):
    model_name = "HierCDF"

    global_params = {}
    global_objects = {"file_manager": FileManager(FILE_MANAGER_ROOT)}
    config_logger(local_params, global_objects)
    config_general_dl_model(local_params, global_params)
    global_params["loss_config"] = {
        "penalty loss": local_params["w_penalty_loss"]
    }
    config_epoch_trainer(local_params, global_params, model_name)
    config_cd_dataset(local_params, global_params, global_objects)
    config_optimizer(local_params, global_params, model_name)
    config_q_table(local_params, global_params, global_objects)

    # 模型参数
    global_params["models_config"] = {
        model_name: {
            "num_concept": local_params["num_concept"],
            "num_question": local_params["num_question"],
            "num_user": local_params["num_user"],
            "itf_type": "mirt",
            "dim_hidden": local_params["dim_hidden"],
        }
    }
    
    # 加载需要的数据
    file_manager = global_objects["file_manager"]
    setting_dir = file_manager.get_setting_dir(local_params["setting_name"])
    graph_dir = os.path.join(setting_dir, "HierCDF")
    graph_path = os.path.join(graph_dir, f"{local_params['dataset_name']}_hier.csv")
    global_objects["HierCDF"] = {
        "know_graph": read_csv(graph_path)
    }

    if local_params["save_model"]:
        setting_name = local_params["setting_name"]
        train_file_name = local_params["train_file_name"]

        global_params["trainer_config"]["save_model_dir_name"] = (
            f"{model_name}@@{setting_name}@@{train_file_name.replace('.txt', '')}@@seed_{local_params['seed']}@@")
        save_params(global_params, MODELS_DIR, global_objects["logger"])
    config_wandb(local_params, global_params, model_name)

    return global_params, global_objects
